(ns comm.wrapper
  (require [comm.translater :refer :all]
           [dna.gen :refer :all]
           [clojure.set :refer :all]
           [clojure.string :as str]
           [clojure.pprint :refer :all]
           [external.matcher :refer :all]
           [dna.generate :refer :all]
           [lib.numbers :refer :all]
           [dna.genes :refer :all]
           )
  (use [clojure.string :only (split)])
  )

(import '(java.net ServerSocket Socket SocketException)
        '(java.io InputStreamReader OutputStreamWriter)
        '(clojure.lang LineNumberingPushbackReader))


;___ active socket is used as a global _____________
(def shrdlu-comms false)


(defn startup-server
  [port]
  (let [ss (new ServerSocket port)]
    (println "advertising " ss)
    (try (let [s (.accept ss)]
           (println "socket accepted " s)

           {:sock s
            :inp  (new LineNumberingPushbackReader
                       (new InputStreamReader (.getInputStream s)))
            :outp (new OutputStreamWriter (.getOutputStream s))
            }
           )
         (catch SocketException e))
    ))

(defn socket-write
  "low-level socket writer"
  [socket x]
  (binding [*out* (:outp socket)]
    (println x)
    ))


(defn socket-read
  "low-level socket reader"
  [socket]
  (read (:inp socket)))

(defn socket-input-waiting
  [socket]
  (.ready (:inp socket)))


;___ netlogo reading/writing _____________

(
  defn set-shrdlu-comms [port]
  (def shrdlu-comms (startup-server port)))

(defn startup [port]

  (set-shrdlu-comms port)

  )
(defn nlogo-send [txt]
  ;(println '** (and shrdlu-comms true) txt)
  (if shrdlu-comms (socket-write shrdlu-comms txt)))

(defn nlogo-read []
  (if shrdlu-comms (socket-read shrdlu-comms)))

(defn nlogo-io-waiting []
  (and shrdlu-comms (socket-input-waiting shrdlu-comms)))

(defn con-read []
  (let [x (nlogo-read)]
    (while (.equals x "stop")
      (println x)
      (swap! x (nlogo-read)))
    )
  )

(defn my-fun [b a]
  (a b))

(defn dnavalue
  "returns dna with its value"
  [gene]
  (concat (list (first gene))
     (doall (map my-fun geans-list (rest gene)))
          (rest gene)
          )
  )

(defn getDna [gene]

    (map gen-gene
         (map parse-int
              (rest (split (apply str gene) #":"))))


  )

(defn fullDna [dna]
  (apply str (flatten (let [dna (getDna dna)]
             (for [x dna
                   y '(:0000:0000:0000:0000)
                   z '(:0101:0000:0101:0000)]
               (flatten [y x z (rand-gene)])
               )
             )))
  )

(defn translate [list-gean]
  (let [x (first list-gean)
        y (rest list-gean)]
    (nlogo-translate-cmd
      (concat
        '(to-nlogo)
        (list x)
        (doall (map my-fun geans-list y))
        (list (fullDna y))
        )
      )
    ))

(defn crt-rabbits [int1]
  (loop [x int1]
    (when (> x 0)
      ;(println x)
      (nlogo-send (translate (new-gean-list x)))
      (recur (- x 1))))
  )
(defn nlogo-send-exec [times]
  (nlogo-send (str "finrepl " times))
  (crt-rabbits times)
  )


(defn concat-all [coll]
  (join " " coll))


(defn n-logosend1
  [results]

  (nlogo-send '(startup))
  (def one (count [:cmds results]))
  (def two "finrepl")
  (prn (count (:cmds results)))
  (nlogo-send (list two one))
  ()
  (doall (map nlogo-send-exec (:cmds results)))
  (:cmds  results)

  )



