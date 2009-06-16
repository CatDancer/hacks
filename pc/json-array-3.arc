(= json-array
  (seq2 (match-is #\[)
        (optional (cons-seq forward.json-value
                            (many (seq2 (match-is #\,)
                                        forward.json-value))))
        (match-is #\])))
