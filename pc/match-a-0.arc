(def match-a (p)
  (if (is car.p #\a)
       (return cdr.p "found A!")))
