(def parse-intersperse (separator parser)
  (optional (cons-seq parser
                      (many (seq2 separator
                                  parser)))))
