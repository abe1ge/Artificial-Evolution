(ns comm.translater
  (require [external.matcher :refer :all])
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

            ((to-nlogo  ?id ?num1 ?num2 )
              :=> (str 'setup-rabbits1 sp (? id) sp (? num1) sp (? num2) ))

            ))



