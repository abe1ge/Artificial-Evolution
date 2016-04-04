; matcher
;===============================
; v(0.0l)

(ns ^{:doc "A Symbolic Pattern Matcher. See user guides and tutorials for detailed information."
      :author "SCL"}
external.matcher)



;--------------------------------------
; globals, etc
;--------------------------------------

; matcher var pseudo name-space

(def
  ^{:doc "Pseudo namespace for matcher variables. Variable mappings are lexically shadowed."}
  mvars {})

(def
  ^{:private true,
    :doc "Set to 'mvars for convenience of macro definitions."
    }
  mns-nam 'mvars)


;--------------------------------------
; helpers for matches
;--------------------------------------

(def rep-?
  ^{:private true,
    :doc "a preset regular expression to detect symbols starting '?'"
    }
  (re-pattern #"\A\?(.+)"))


(def rep-??
  ^{:private true,
    :doc "a preset regular expression to detect symbols starting '??'"
    }
  (re-pattern #"\A\?\?(.+)"))


(defn- has-?-prefix
  "a predicate to check if a symbol has '?' prefix (but not '??' prefix)"
  [sym]
  (and (re-find rep-? (str sym))
       (not (re-find rep-?? (str sym)))))


(defn- has-??-prefix
  "a predicate to check if a symbol has '??' prefix"
  [sym]
  (re-find rep-?? (str sym)))


(defn- strip-first
  "strip first '?' char from a symbol/string, returning a symbol"
  [sym]
  (symbol ((re-find rep-? (str sym)) 1)))


(defn- strip-first2
  "strip first '??' chars from a symbol/string, returning a symbol"
  [sym]
  (symbol ((re-find rep-?? (str sym)) 1)))



;--------------------------------------
; fn: matches & associated fns
;--------------------------------------

(declare matcher:matches-)

(defn- apply-all-predicates
  "ripple a value through a a sequence of predicates failing if any return false/nil.
  When predicates return true the value is unchanged, other non-false values replace
  the existing value."
  [x fns]
  (if (empty? fns) x
                   (if-let [y ((first fns) x)]
                     (recur (if (= y true) x y) (rest fns))
                     )))



(defn- eval-fns
  "takes a sequsence of (i) functions and/or (ii) textual forms describing functions,
  returns a sequence of functions (textual forms are evaluated)"
  [fns]
  (map #(if (fn? %) % (eval %)) fns))



(defn- absorb
  "a core matcher function which binds multiple values for '??x' type variables.
  Implements a mutually recursive depth-first search with matches"
  [vnam p d bind & {:keys [predicates]}]
  ; NB: p is the remaining part of pattern
  ; vnam is the name of the absorbing var
  ; predicates is a list of fns to run bindings through
  ; predicates will normally be quoted hence the test & mapping
  (let [predicates (eval-fns predicates)]
    (loop [vbind () ; the value bound to vnam
           data d ; the remaining data
           ]
      ;(println "absorb vb=" vbind " p=" p " d=" d)
      (if-let [new-vbind (apply-all-predicates vbind predicates)]
        (let [res (matcher:matches- p data (assoc bind vnam new-vbind))]
          ;(println "--absorb new-vb=" new-vbind " res=" res)
          (cond res res
                (empty? data) nil
                :else (recur `(~@vbind ~(first data)) (rest data))
                ))
        ; if-let else
        (if (empty? data) nil
                          (recur `(~@vbind ~(first data)) (rest data))
                          )
        ))))



(defn matcher:matches-
  "The main matcher function. This function should not be called directly,
  it is visible (ie: not private) so calls can be pushed into client code by macros.
  The naming convention 'matcher:foo-' is used to half-hide forms which should only
  be accessed by macros."
  [p d bind]
  (cond

    ;__ tree down to level of symbols ____________
    (= p d) bind ; p = d      => bind
    (= p '?_) bind ; p is wild  => bind

    (has-?-prefix p) ; p isa ?var
    (if-let [b (bind (strip-first p))] ; if ?var is bound
      (and (= b d) bind) ;     check match
      (assoc bind (strip-first p) d)) ; else bind it

    ; first check for a pair of maps
    (and (map? p) (map? d))
    (recur (sort (seq p)) (sort (seq d)) bind)  ; line them up for matching

    ; now check for other collections
    (and (coll? p) (not (empty? p))) ; p is non-empty seq
    (cond
      ;__  (-> ?var pred..) _____
      (and (= (first p) '->) (has-?-prefix (second p)))
      (let [[v & preds] (rest p)  ; this will trip an error if the pattern
            v (strip-first v)    ; is badly formed but i guess this is ok
            ]
        (if-let [r (apply-all-predicates d (eval-fns preds))]
          (assoc bind v r))
        )

      ;__ tree one level up _________________________

      ;__  (-> ??var pred..)... _____
      (and (coll? (first p)) (= (ffirst p) '->)
           (has-??-prefix (second (first p))))
      (let [[_ v & preds] (first p)    ; error on badly formed pattern
            v  (strip-first2 v)
            ]
        (absorb v (rest p)
                d bind :predicates preds))


      ;__  ??_  ________
      (= (first p) '??_)
      (absorb (gensym 'tmp) (rest p) d bind)

      ;__  ??var  ______
      (has-??-prefix (first p))
      (absorb (strip-first2 (first p)) (rest p) d bind)

      ;__  data is a list ____
      (and (coll? d) (not (empty? d))) ; d is non-empty seq
      (if-let [b (matcher:matches- (first p) (first d) bind)]
        (recur (rest p) (rest d) b) ; match first & rest
        nil)

      :else nil
      )

    :else nil
    ))




(defmacro matches
  "the most primitive matching form, matches a pattern against data.
  This is a low-level form, it will not usually be called directly"
  ([p d] `(matcher:matches- ~p ~d (merge ~mns-nam {:pat ~p :it ~d})))
  ([p d bind] `(matcher:matches- ~p ~d (merge ~mns-nam {:pat ~p :it ~d} ~bind)))
  )

(defmacro with-timeout [time & body]
  `(thunk-timeout (fn [] ~@body) ~time))


;--------------------------------------
; match out, mout
;--------------------------------------


(defn matcher:mout-
  "build structured output from a mixture of literals and bound match variables.
  The naming convention 'matcher:foo-' is used to half-hide forms which should only
  be accessed by macros."
  [x mvars]
  ;(println "** x=" x ", mvars=" mvars)

  (if (coll? x)                  ;__ collections ___________________________
    (cond
      (empty? x)  x              ; so nils are not transformed to ()
      ; & vectors, etc have types preserved
      (vector? x) (into [] (matcher:mout- (seq x) mvars))
      (map? x)    (into {} (matcher:mout- (seq x) mvars))

      ; other, including specials that must be handled at non-terminals...
      (seq? x)
      (let [[f & r] x]
        (cond
          ; check ??var
          (has-??-prefix f)
          (let [f (or (mvars (strip-first2 f)) f)]
            (if (seq? f)
              (concat f (matcher:mout- r mvars))
              (cons f (matcher:mout- r mvars))
              ))

          ; check :eval clause
          (= f :eval)
          ((eval `(fn [~mns-nam] ~@r)) mvars)

          ; default list case
          :else
          (cons (matcher:mout- f mvars) (matcher:mout- r mvars))
          )))

    ;__ atomics _____________________________

    (cond
      ; check ?var
      (has-?-prefix x)
      (or (mvars (strip-first x)) x)

      ; default case -- leave it unchanged
      :else x
      )))



(defmacro mout [lis]
  "mout (matcher-out) is a convenience form to build structured output
  from a mixture of literals and bound match variables"
  `(matcher:mout- ~lis ~mns-nam))



;--------------------------------------
; macros: ?, mlet, with-mvars
;--------------------------------------


(defmacro ?
  "lookup named variable in matcher name-space"
  [x]
  `(~mns-nam '~x))


(defmacro with-mvars
  "add a map of variable names  and values to mvars then
  evaluates the body in this context.

  example...
  user=> (with-mvars {'a (+ 2 3), 'b (- 3 4)}
           (println mvars)
           (with-mvars {'b 'bb, 'd 'xx, 'e 'yy}
             (println mvars)))
  {b -1, a 5}
  {e yy, d xx, b bb, a 5}"
  [vmap & body]
  `(let [~mns-nam (merge ~mns-nam ~vmap)]
     ~@body
     ))



(defmacro mlet
  "a matcher form of let, the most primitive form of matcher expression provided for general use.
  eg: (mlet ['(?x ?y ?z) '(cat dog bat)] (? y)) => dog"
  [[p d] & body]
  `(if-let [mbind# (matches ~p ~d)]
     (let [~mns-nam mbind#]
       ~@body)
     ))



;--------------------------------------
; macros: mif
;--------------------------------------

(defmacro mif
  "a matcher form of if with an optional 'else' clause
  (mif [pattern data] then-clause else-clause)"
  ([[p d] then rest]
   `(if-let [~mns-nam (matches ~p ~d)]
      ~then ~rest))
  ([[p d] then]
   `(if-let [~mns-nam (matches ~p ~d)]
      ~then))
  )


;--------------------------------------
; macros: mcond
;--------------------------------------


(defmacro mcond
  "mcond is the most general of the switching/specialisation forms,
  it can be used to specify a series of pattern based rules as follows:

  (defn calc [exp]
    (mcond [exp]
      ([?a minus ?b] :=> (- (? a) (? b)))
      ([?a plus ?b]  :=> (+ (? a) (? b)))
      ( ?_           :=> 'unknown )
      ))
  NB: use of :=> above is optional"
  [[lis] & forms]
  (let [lis lis ;; eval only once
        body (for [f forms]
               `(mlet ['~(first f) ~lis] ~@(rest f))
               )]
    `(or ~@body)
    ))



;--------------------------------------
; macros: mfind, mfind*
;--------------------------------------


(defmacro mfind
  "find an occurance of a pattern in a collection of data"
  [[p data] & body]
  `(loop [d# (seq ~data)]
     (if (empty? d#) nil
                     (if-let [r# (mlet [~p (first d#)] ~@body)]
                       r#
                       (recur (rest d#))
                       ))))



(defmacro mfind*
  "using multiple patterns, find a consistent match of all patterns in a collection of data"
  [[pats data] & body]
  (let [data data ;; eval only once
        pats pats ;; ditto
        ]
    `(letfn [(f# [ps# ds# ~mns-nam]
               ;(println mvars)
               (cond
                 (empty? ps#) ; all pats have matched
                 (do ~@body)

                 (empty? ds#) ; data exhausted
                 nil

                 (= :not (ffirst ps#))
                 (let [x# (f# (rest (first ps#)) ~data ~mns-nam)]
                   (if x# nil (f# (rest ps#) ~data ~mns-nam)))

                 (= :guard (ffirst ps#))
                 (let [foo# (eval `(fn [~'~mns-nam]
                                     (and ~@(rest (first ps#)))))
                       ]
                   (and (foo# ~mns-nam)
                        (f# (rest ps#) ~data ~mns-nam)))

                 :else
                 (or (mlet [(first ps#) (first ds#)]
                           (f# (rest ps#) ~data ~mns-nam))
                     (f# ps# (rest ds#) ~mns-nam)
                     )
                 ))
             ]
       (f# ~pats ~data ~mns-nam)
       )))





;--------------------------------------
; macros: mfor, mfor*
; fn:     matcher:strict-map
;--------------------------------------


(defn matcher:strict-map
  ; like map but not lazy
  ; TODO: replace this with appropriate do- form
  [foo data]
  (if (empty? data) data
                    (cons (foo (first data)) (matcher:strict-map foo (rest data)))
                    ))


(defn matcher:safely-concat [data]
  ; used in mfor* so its body can return symbolic forms
  ; TODO: check this and replace
  (remove #(= % nil)
          (if (every? seq? data)
            (reduce concat data)
            data)))


(defmacro mfor
  "find multiple occurances of a pattern in a collection of data.
  The body is evaluated for each occurance found, mfor returns a sequence
  of the results of these evaluations"
  [[p data] & body]
  `(remove #(= % nil)
           (matcher:strict-map (fn [d#] (mlet [~p d#] ~@body)) ~data)))


(defmacro mfor*
  "using multiple patterns, find all consistent matches of all patterns in a collection of data.
  The body is evaluated for each consistent match found, mfor* returns a sequence
  of the results of these evaluations"
  [[pats data] & body]
  (let [data data ;; eval only once
        pats pats ;; ditto
        ]
    `(letfn [(f# [p# ~mns-nam]
               (cond
                 (empty? p#)
                 (do (list ~@body))

                 (= :not (ffirst p#))
                 (let [x# (mfind* [(rest (first p#)) ~data] true)]
                   (if x# nil (list (f# (rest p#) ~mns-nam))))

                 (= :guard (ffirst p#))
                 (let [foo# (eval `(fn [~'~mns-nam]
                                     (and ~@(rest (first p#)))))
                       x# (foo# ~mns-nam)
                       ]
                   (if x# (list (f# (rest p#) ~mns-nam))))

                 :else
                 (matcher:safely-concat
                   (mfor [(first p#) ~data]
                         (f# (rest p#) ~mns-nam))
                   )
                 ))]
       (matcher:safely-concat (f# ~pats ~mns-nam))
       )))



;--------------------------------------
; macros: defmatch mfn
;--------------------------------------


(defmacro defmatch
  "defmatch is similar in structure to mcond, wrapping an implicit mcond form with a
  function definition, eg:

  (defmatch math2 [x]
    ((add ?y)  :=> (+ x (? y)))
    ((subt ?y) :=> (- x (? y)))
    ( ?_       :=> x))

  (math2 '(add 7) 12) => 19
  (math2 '(subt 7) 12) => 5
  (math2 '(times 7) 12) => 12"
  [name params & forms]
  (let [exp (gensym 'exp)
        params (into [exp] params)
        ]
    `(defn ~name ~params
       (mcond [~exp]
              ~@forms)))
  )


;(defmatch blah []
;  ((?a ?b ?c)  :=> 'do-summin)
;  ((whoops ?x) :=> 'do-summin-else)
;  )

(defmacro mfn
  "defines an anonymous match form similar to defmatch"
  [params & forms]
  (let [exp (gensym 'exp)
        params (into [exp] params)
        ]
    `(fn ~params
       (mcond [~exp]
              ~@forms)))
  )


;--------------------------------------
; macros: massert
;--------------------------------------

(defmacro massert
  "massert offers a run-time assertion mechanism based on patterns"
  [[pat dat] text]
  `(if-not (matches ~pat ~dat) (throw (RuntimeException. ~text))))



;---- eof ----------------------------------------------------------------
;-------------------------------------------------------------------------
