(ns comm.translater
  (require [external.matcher :refer :all]
           [lib.numbers :refer :all]
           [lib.maps :refer :all]
           [dna.genes :refer :all]
           [evolve.mutation :refer :all]
           [dna.transcription :refer :all]
           )
  (use [clojure.string :only (split)]))



(defn fmlogo
  [mes]

  (println (first (split mes #"dna")))

  (if (empty? (first (rest (split mes #"dna"))))
    "no dna"
  (println (let [agent mes
                 dna (first (rest (split agent #"dna")))
                 mutated (mutate dna)
                 ]
             (println  (val-exess (first (rest (split agent #"dna")))))
             (val-exess (str mutated ":0101:0000"))
             )))
 ; (println (mutate (str (first (rest (split mes #"dna"))))))
  ;(println (mutate (first (rest (split mes #"dna")))))
  ;(println (first (rest (split mes #":"))))
;  (println (class(first (rest (split mes #":")))))
;  (println (keyByValue (String->Number (first (rest (split mes #":")))) speed))
  )


(let [
      sp    " "
      qt    "\""
      str-qt   (fn[x] (str " \"" x "\" "))    ; wrap x in quotes
      axis-no (fn[x] (apply str (rest (str x))))   ; strip first letter of axis name

      ]

  (defmatch nlogo-translate-cmd []

            ((create ?nam )
              :=> (str 'exec.make (str-qt (? nam)) sp (str-qt(axis-no (? nam)))  ))

            ((to-nlogo  ?id ?num1 ?num2 ?num3)
              :=> (str 'setup-rabbits1 sp (? id) sp (? num1) sp (? num2) sp (str-qt(? num3)) ))

            ))



