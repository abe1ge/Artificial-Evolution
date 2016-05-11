(ns comm.nexec
  (require [comm.wrapper :refer :all])
  )

(defn call
  "takes a string and arguments
   match string to namespace
   apply string to arguemnts"
  [^String nm & args]
  (when-let [fun (ns-resolve *ns* (symbol nm))]
    (apply fun args)
    )
  )

(defn reading
  "read first number from nlogo n put in x
  continue reading fron nlogo"
  []
  (loop [x (+ 1 (nlogo-read))
         result []]
    (if (= x 0)
      (do
        (println "recived: " result)
        result)
      (recur (- x 1)
             (conj result (nlogo-read)))
      ))
  )

(defn exec
  "apply first of list to rest of list
  first can be function or a string"
  [str]
  (try
    (do
      (println (apply call (first str) (rest str)))
      (nlogo-send (apply call (first str) (rest str))))
    (catch Exception e
      (do
        (println (apply (first str) (rest str)))
        (nlogo-send(apply (first str) (rest str))))
      ))
  )

(defn setup
  "startup on port 2222
  if that is in use try port + 1"
  [x]
  (try
    (startup x)
    (catch Exception e
      (println (str "Exception: " (.getMessage e)))
      (setup (+ 1 x))
      ))
    )

(defn online?
  "recuring
  if connected to port run exec
  else run setup"
  []
  (if shrdlu-comms
    (do (exec (reading))
        (online?))
    (do (setup 2222)
        (online?))
    ))























;(defn listen [mes]
;     (arange)
;     (listen (nlogo-read))
;  )
;
;(defn light [mes]
;  (let [x mes]
;    (if (= x "stop")
;      (println x)
;      (arange)
;    )))
;(defn arange []
;  (let [cmd  (nlogo-read)
;        arg1 (nlogo-read)
;        arg2 (nlogo-read)
;        ]
;    (nlogo-send (call cmd arg1 arg2))
;    (light (nlogo-read))
;    ))