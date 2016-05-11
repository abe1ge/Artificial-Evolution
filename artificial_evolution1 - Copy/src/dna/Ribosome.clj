(ns dna.Ribosome
  (require [lib.maps :refer :all]
           [dna.genes :refer :all]))
;;reads messenger RNA outputed by transcription
;;and produces a phenome (in real life this is a gene
;;but that process is unessessory when working on binary
;;and it will make this model more complicated then it needs to be
;;this phenome can still be interpred as a gene
;;but that process needs to be done where with in the environment
;;where the agent is applied

;;in biology this would only interpret one Transfer RNA
;;and output its result as a protein
;;but this doesn't make sence for this structure and
;;will make the code more complex and dificult to understand
;;therofre the whole genome is going to be interpreted
;;and it is going to output the wole genome


(defn find-key
  "this returns the keys giving
  the start and ending  index
  because it is recursive it returns it backwords"
  [DNA start end]
  (loop [end1 end
         result []]
    (if-not (> end1 start)
      result
      (recur (- end1 1)    ;loop with 2 new arguments
             (conj result (nth DNA end1)))))
  )

(defn val-gene
  "this takes RNA DNA"
  [RNA start end]
  (reduce + (map-list Transfer-Rna
                      (find-key RNA start end)
                      ))
  )
