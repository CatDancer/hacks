(= json-object-kv
  (with-seq (key   json-string
             colon (match-is #\:)
             value forward.json-value)
    (list key value)))
