 (ns expotess)


(defn crt-rabbits [int1]
      "creaes a set number of rabbits"
      (loop [x int1]
            (when (> x 0)
                  (println x)
                  (nlogo-send (translate (new-gean-list x))) ;;creates a new gene and translate it
                  (recur (- x 1))))
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
(defn unary [num]
      (for [x (range num)
            y [15]]
           (first [y x])
           )
      )

(def gene-start ":0000:0000")
(def gene-end ":0101:0000")

(def test-rnaM '(:0001 :1010 :0000 :1100
                  :0000 :0000 :0000 :0000
                  :1001 :0000 :1101 :1111
                  :0001 :1010 :0000 :1100
                  :0101 :0000 :0101 :0000
                  :1001 :0000 :1101 :1111
                  :0001 :1010 :0000 :1100
                  :0001 :1010 :0000 :1100
                  :0000 :0000 :0000 :0000
                  :1011 :0000 :1111 :1111
                  :1001 :0000 :1101 :1111
                  :0001 :1010 :0000 :1100
                  :0001 :1010 :0000 :1100
                  :0000 :0000 :0000 :0000
                  :1011 :0000 :1111 :1111
                  :0101 :1110 :0000 :1110
                  :0000 :0000 :0000 :0000
                  :1011 :0000 :1111 :1111
                  :1001 :0000 :1101 :1111
                  :0000 :0000 :0000 :0000
                  :1011 :0000 :1111 :1111
                  :1001 :0000 :1101 :1111
                  :0101 :0000 :0101 :0000
                  :1001 :0000 :1101 :1111))
