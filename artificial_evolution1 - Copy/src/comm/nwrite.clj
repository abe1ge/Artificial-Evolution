(ns comm.nwrite
  (require [comm.translater :refer :all]
           [dna.gen :refer :all]
           [evolve.mutation :refer :all]
           [dna.transcription :refer :all]
           [lib.numbers :refer :all]
           [comm.wrapper :refer :all])
  (use [clojure.string :only (split)]))




(defn mutated-nlogo
  "sending mutated gene back to nlogo"
  [mes]

  (if (empty? (first (rest (split mes #"dna"))))
    (do
      (crt-rabbits 1)
        (println "created new rabbit")
        (println (empty? (first (rest (split mes #"dna"))))))
    (let [agent mes
                   dna (first (rest (split agent #"dna")))
                   mutated (mutate dna)
                   updated (apply list (val-exess (str mutated ":0101:0000")))
                   id (+ 1 (parse-int (first (split (first (split mes #"dna")) #":"))))
                   ]

      (println updated)
               (println (translate (concat (list id)
                                           (for [x updated
                                                 y [keyword]
                                                 ]
                                             (y (str x))
                                             ))))

               (nlogo-send (translate (concat (list id)
                                (for [x updated
                                      y [keyword]
                                      ]
                                  (y (str x))
                                  ))))   ))  )

(defn nlogo-send-chage

  [mes]
    (do
      (nlogo-send (str "finrepl " 1))
      (mutated-nlogo mes)
      (println (count mes)))

  )

;   (println (second updated))
              ; (println-str "translate finished")
               ;(let [keyed (map keyword (map str (val-exess (str mutated ":0101:0000"))))
               ;      ;dna (conj id keyed)
               ;      ]
               ;
               ;  (println (apply rollup keyed))
               ;
               ;  )

              ; (val-exess (str mutated ":0101:0000"))


  ; (println (mutate (str (first (rest (split mes #"dna"))))))
  ;(println (mutate (first (rest (split mes #"dna")))))
  ;(println (first (rest (split mes #":"))))
  ;  (println (class(first (rest (split mes #":")))))
  ;  (println (keyByValue (String->Number (first (rest (split mes #":")))) speed))

