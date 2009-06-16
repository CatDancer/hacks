(= json-backslash-escape
  (seq2 (match-is #\\)
        (alt (seq2 (match-is #\u)
                   fourhex)
             (fn (p)
               (return cdr.p (json-backslash-char car.p))))))
