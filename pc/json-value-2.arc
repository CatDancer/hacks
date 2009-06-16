(= json-value
  (alt json-string
       json-number
       json-object
       json-array
       json-true
       json-false
       json-null))
