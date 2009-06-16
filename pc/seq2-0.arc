(def seq2 parsers
  (with-result results (apply seq parsers)
    (results 1)))
