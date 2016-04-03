(ns dna.gen
  (require [dna.definitions :refer :all]
           ))

(def mygean1 "101010001010101010")

(defn gen-gean [num ]
  (def mygean1 "1 ")
  (println mygean1)
  (loop [x num]
    (when (> x 1)
      (def mygean1
        (str mygean1 (rand-int 2))
        )
      (recur (- x 1))))
  )

(def agent1 "(setup-rabbits1 0.1 blue 123)")

;id #speed #color #max-age
(defn str-int [str]
  (let [n (read-string str)]
    (if (number? n) n nil)))