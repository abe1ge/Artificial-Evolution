(ns comm.nread
  (require [comm.wrapper :refer :all]))

(defn nlogo-str []
  (str (nlogo-read)))

(defn nread-check [mes]
  (if (not= mes "stop")
    (do (println mes)
        (nlogo-send-exec 1)
        (nread-check (nlogo-str))
        )
    (println "I am stoping" mes)
    ))
;(defn cnt-nread [mes]
;  (if (not= mes "stop")
;    ((println mes)
;      (cnt-nread (nlogo-str))
;      )
;    )
;  (println mes))
;
;(defn nread-check []
;  (let [mes (nlogo-str)]
;  (if (not= mes "stop")
;    (do (nlogo-send-exec 1)
;      (cnt-nread (nlogo-str))
;      )
;    (println "I am stoping" mes)
;    )))
;
;(defn handel-exc [fun]
;  (try
;    fun
;    (catch Exception e (str "Caught exception: " e))))

