(ns artificial-evolution.wrappers)
(require '[clojure.set :refer :all])
(require '[clojure.string :as str])
(require '[clojure.pprint :refer :all])





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


(declare nlogo-translate-cmd)

(defn nlogo-send-exec [cmd-list]
  ; (ui-out :comm 'NL==> cmd-list)
  ;(println cmd-list "First")

   (nlogo-send (nlogo-translate-cmd cmd-list))
  ;(let [cmd-str (nlogo-translate-cmd cmd-list)])
  ; (let [cmd-list (nlogo-translate-cmd cmd-list)])
  (println cmd-list "Sent _"
            ;  (nlogo-send cmd-str)

           ))
(defn concat-all [coll]
  (join " " coll))


(defn n-logosend1
[results]


(nlogo-send '(startup))

(def one (count [:cmds results]))
(def two "finrepl")

(prn (count (:cmds results)))
 (nlogo-send (list two one))
;(nlogo-send-exec (:cmds results))
; (doall (map (nlogo-send-exec (:cmds results))))
; (doall (map nlogo-send-exec :cmds))
;  (doall (map nlogo-send-exec (:cmds results)))
()
(doall (map nlogo-send-exec (:cmds results)))
(:cmds  results)
;get the cmds from results and send it to nlogo-send-exec
)



;(declare nlogo-translate-cmd)
;(def cmd1 '((at Tblue c3)))
;
;(defn test1 [cmd]
;  (n-logosend1 (ops-search state cmd ops :world world))
;  )