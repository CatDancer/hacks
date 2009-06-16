(= json-array
  (seq2 (match-is #\[)
        (optional (seq (fn (p) (json-value p))
                       (many (seq2 (match-is #\,)
                                   (fn (p) (json-value p))))))
        (match-is #\])))
