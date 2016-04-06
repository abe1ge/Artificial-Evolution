(ns dna.gen
  (require [dna.definitions :refer :all]
           [lib.numbers :refer :all]
           [lib.maps :refer :all]
           )
  (use [clojure.string :only (split)]))

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

;Chang string to int
(defn str-int [str]
  (let [n (read-string str)]
    (if (number? n) n nil)))


(def geans-list [speed colour])


;;find the gean from gene list using which gene it is
(defn find-gene []
  (parse-int (str (rand-key speed)))
  )

(defn new-gean-str [id]
  (let [x id]
    (str x (rand-key speed) (rand-key colour))
    )
  )

(defn new-gean-list [id]
  (let [x id]
    (list x (rand-key speed) (rand-key colour))
    )
  )

(defn sep-gean [gean]
  (split gean #":")
  )


