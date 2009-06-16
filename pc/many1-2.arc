(def many1 (parser)
  (on-result (fn ((r1 rs))
               (cons r1 rs))
             (seq parser
                  (many parser))))
