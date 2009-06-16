(= json-array
  (seq2 (match-is #\[)
        (optional (seq forward.json-value
                       (many (seq2 (match-is #\,)
                                   forward.json-value))))
        (match-is #\])))
