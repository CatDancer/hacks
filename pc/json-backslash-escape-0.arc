(= json-backslash-escape
  (seq (match [is _ #\\])
       (alt (seq (match [is _ #\u])
                        fourhex)
            (fn (p)
              (return cdr.p (json-backslash-char car.p))))))
