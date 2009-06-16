(def seq parsers
  (fn (p)
    ((afn (p parsers a)
       (if parsers
            'do-something-with-the-next-parser
            (return p rev.a)))
     p parsers nil)))
