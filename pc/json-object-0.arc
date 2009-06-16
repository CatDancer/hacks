(= json-object
   (on-result listtab
     (seq2 (match-is #\{)
           (comma-separated json-object-kv)
           (match-is #\}))))
