(ns artificial-evolution.core
  (:gen-class)
  (require [comm.wrapper :refer :all]
           [dna.gen :refer :all]
           [dna.genes :refer :all]
           [comm.nread :refer :all]
           [lib.maps :refer :all]
           [comm.translater :refer :all]
           [lib.numbers :refer :all]
           [dna.generate :refer :all]
           [dna.Ribosome :refer :all]
           [dna.transcription :refer :all]))


(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  ;(println (speed :0010))

  (println (translate (new-gean-list 3)))
  ;(gen-gean 12)
  ;(println mygean1)
  ;(println (str-int mygean1))
  ;(startup 2223)
  ;(nlogo-send mygean1)


  (println "Hello, World!"))
