(= json-array
  (seq2 (match-is #\[)
        (optional (seq json-value
                       (many (seq2 (match-is #\,)
                                   json-value))))
        (match-is #\])))
