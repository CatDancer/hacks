(= json-number
  (with-result cs (many1 json-number-char)
    (coerce (coerce cs 'string) 'num)))
