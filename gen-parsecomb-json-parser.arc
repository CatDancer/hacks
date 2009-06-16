(def readfilec (name)
  (apply string
    (w/infile i name (drain (readc i)))))

(def gen (filename lst)
  (w/outfile o (string "~/git/pub/" filename)
    (each inf lst
      (disp (readfilec inf) o)
      (disp #\newline o))))

(gen "parsecomb0.arc"
     '("pc/return-0.arc"
       "pc/match-0.arc"
       "pc/alt-0.arc"
       "pc/seq-1.arc"
       "pc/many-0.arc"
       "pc/on-result-0.arc"
       "pc/with-result-0.arc"
       "pc/with-seq-0.arc"
       "pc/cons-seq-0.arc"
       "pc/many1-5.arc"
       "pc/must-0.arc"
       "pc/seq2-0.arc"
       "pc/optional-2.arc"
       "pc/forward-0.arc"
       "pc/match-is-0.arc"
       "pc/match-literal-0.arc"
       "pc/parse-intersperse-0.arc"
       "pc/comma-separated-0.arc"))

(gen "json-parser0.arc"
     '("pc/json-literals-0.arc"
       "pc/json-number-char-0.arc"
       "pc/json-number-1.arc"
       "pc/fourhex-0.arc"
       "pc/json-backslash-char-0.arc"
       "pc/json-backslash-escape-1.arc"
       "pc/json-string-0.arc"
       "pc/json-array-4.arc"
       "pc/json-object-kv-0.arc"
       "pc/json-object-0.arc"
       "pc/json-value-2.arc"
       "pc/fromjson-0.arc"))
