(ns comm.nwrite
  (require [comm.translater :refer :all]
           [dna.gen :refer :all]))

(defn nlogotranslate [id]
  (nlogo-translate-cmd (concat '(try) (new-gean-list id))))

