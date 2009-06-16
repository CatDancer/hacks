(= json-string
  (with-result cs (seq2 (match-is #\")
                        (many (alt json-backslash-escape
                                   (match [isnt _ #\"])))
                        (match-is #\"))
    (coerce cs 'string)))
