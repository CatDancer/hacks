(= json-value
  (alt json-string
       json-number
       json-array
       json-true
       json-false
       json-null))
