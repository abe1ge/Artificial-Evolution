(ns dna.gen
  (require [dna.definitions :refer :all]
           [comm.translater :refer :all]
           [lib.numbers :refer :all]
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


;;get the key for a gene
(defn get-gene [gean]
  (let [x (rand-nth (keys gean))]
    x
    )
  )

;;find the gean from gene list using which gene it is
(defn find-gene []
  (parse-int (str (get-gene speed)))
  )

(defn new-gean-str [id]
  (let [x id]
    (str x (get-gene speed) (get-gene colour))
    )
  )

(defn new-gean-list [id]
  (let [x id]
    (list x (get-gene speed) (get-gene colour))
    )
  )

(defn sep-gean [gean]
  (split gean #":")
  )

(defn get-color []
  (rand-nth (vec colour)))

(defn nlogotranslate [id]
  (nlogo-translate-cmd (concat '(try) (new-gean-list id))))