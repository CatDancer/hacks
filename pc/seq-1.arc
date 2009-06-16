(def seq parsers
  (fn (p)
    ((afn (p parsers a)
       (if parsers
            (iflet (p2 r) (car.parsers p)
              (self p2 cdr.parsers (cons r a)))
            (return p rev.a)))
     p parsers nil)))
