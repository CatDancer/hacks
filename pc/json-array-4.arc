(= json-array
  (seq2 (match-is #\[)
        (comma-separated forward.json-value)
        (match-is #\])))
