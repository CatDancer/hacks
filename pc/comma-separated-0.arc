(def comma-separated (parser)
  (parse-intersperse (match-is #\,) parser))
