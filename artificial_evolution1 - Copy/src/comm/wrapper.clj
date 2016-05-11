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
  defn set-shrdlu-comms
  "set"
  [port]
  (def shrdlu-comms (startup-server port)))

(defn startup
  "if port num is not in use
  create a socket on that port and advertise
  "
  [port]
  (set-shrdlu-comms port)

  )
(defn nlogo-send
  "send a string to netlogo"
  [txt]
  ;(println '** (and shrdlu-comms true) txt)
  (if shrdlu-comms (socket-write shrdlu-comms txt)))

(defn nlogo-read []
  (if shrdlu-comms (socket-read shrdlu-comms)))

(defn nlogo-io-waiting []
  (and shrdlu-comms (socket-input-waiting shrdlu-comms)))

(defn con-read
  "read from netlogo till told stop"
  []
  (let [x (nlogo-read)]
    (while (.equals x "stop")
      (println x)
      (swap! x (nlogo-read)))
    )
  )

(defn my-fun
  "takes two arguments and run one as function on the toher"
  [b a]
  (a b))

(defn dnavalue
  "01 returns dna with its value"
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
  "gets a random gene and apply gene start and end"
  (apply str (flatten (let [dna (getDna dna)]
             (for [x dna
                   y '(:0000:0000)
                   z '(:0101:0000)]
               (flatten [y x z (rand-gene)])
               )
             )))
  )

(defn translate [list-gean]
  "gets dna > gets all value for gene,
  combines values with dna
  ready to be sent to nlogo"
  (let [x (first list-gean)
        y (rest list-gean)]
    (nlogo-translate-cmd  ;translate dna for nlogo
      (concat
        '(to-nlogo)
        (list x)
        (doall (map my-fun geans-list y))
        (list (fullDna y))  ;;attach full dna at the end
        )
      )
    ))


(defn crt-rabbits [int1]
  "creaes a set number of rabbits"
  (loop [x int1]
    (when (> x 0)
      (println x)
      (nlogo-send (translate (new-gean-list x))) ;;creates a new gene and translate it
      (recur (- x 1))))
  )

(defn nlogo-send-exec
  "creates a number of rabbits and allow nelogo to set
  them all up"
  [times]
  (nlogo-send (str "finrepl " times)) ;tell nlogo to run thme
  (crt-rabbits times)
  )







