(def assoc (key al)
  (if (atom al)
       nil
      (and (acons (car al)) (iso (caar al) key))
       (car al)
      (assoc key (cdr al))))

(edef code content
  `(blockquote () (pre () ,(esc (apply string content)))))

(= darc (qu "<code>.arc</code>"))

(def indent xs
  `(div (style "margin-left: 2em") ,@xs))

(def readfilec (name)
  (apply string
    (w/infile i name (drain (readc i)))))

(def ef (name)
  (readfilec (string "~/git/hacks/" name ".arc")))

(= arc* "/tmp/arc")

(do ((mz current-directory) "/tmp")
    (system "rm -rf arc arc3 arc3.tar")
    (system "tar xf ~/download/arc3.tar")
    (system "mv arc3 arc")
    (system "cp -v ~/git/hacks/as2.scm arc/")
    )

(def writen (x s)
  (write x s)
  (disp #\newline s))

(def chomp-left (s)
  (if (begins s "\n")
       (cut s 1)
       s))

(def chomp-right (s)
  (if (endmatch "\n" s)
       (cut s 0 (- (len s) 1))
       s))

(def chomp-both (s)
  (chomp-right (chomp-left s)))

(def display-expr (expr)
  (pr "arc> ")
  (each c (chomp-both expr)
    (if (is c #\newline)
         (do (prn)
             (pr "     "))
         (pr c)))
  (prn))

(def execute (loads exprs)
  erp.loads
  erp.exprs
  ((mz current-directory) arc*)
  (w/outfile
   o "run.arc"
   (each f loads
     (writen `(load ,f) o))
   (each expr exprs
     (write `(output ,expr) o)
     (disp #\newline o))
   (writen '(quit) o))
  (prn "------")
  (system "cat run.arc")
  (prn "------")
  (prn ">>>")
  (let s (tostring (system "mzscheme -m -f as2.scm"))
    (prn "<<<")
    (disp s)
    (fromstring s (drain (read)))))

(def example (loads exprs)
  (prn)
  (prn)
  (prn "******************* example")
  (let rs (execute (cons "~/git/hacks/output.arc"
                         (map (fn (f)
                                (string "~/git/hacks/" f))
                              loads))
                   exprs)
    `(blockquote ()
       ,@(map (fn (in out)
                (aif (alref out 'error)
                      `((pre ()
                          ,(esc:tostring
                            (display-expr in)
                            (disp (alref out 'out))
                            (prn)))
                        (i () ,(esc it)))
                      `((pre ()
                          ,(esc:tostring
                            (display-expr in)
                            (disp (alref out 'out))
                            (disp (alref out 'result)))))))
              exprs rs))))

(def tag (hack/tag)
  (if (acons hack/tag)
       hack/tag
      (isa hack/tag 'table)
       (list hack/tag!name hack/tag!version)
       (err "what's this?" hack/tag)))

(def tagname (hack/tag)
  (let (name version) (tag hack/tag)
    (string name version)))

(def snag (name)
  (eval (readfile1 (string "~/git/hacks/" name ".doc"))))

(= hacks* (map snag
  '(ac
    list-writer
    table-reader-writer
    defvar
    dyn
    srv-mime
    erp
    exit-on-eof
    toerr
    json
    extend
    load-rename
    emacs-utf8
    nil-impl-by-null
    parser-combinator-approach-to-json
    )))

(def gen-bugs (hack)
  (aif hack!bugs
       `((h3 () "bugs")
         (ul ()
           ,@(map (fn (bug)
                    `(li () ,bug))
                  it))
         ;; TODO dup /tree
         ;;"Have fixes?  Send them to me on <a href=\"" ,(git-repo-http hack) "/tree\">GitHub</a>."
         )))

(def homepage (hack)
  (or hack!homepage
      (string hack!name ".html")))

(def title (hack)
  (string (or hack!title hack!name)))

(def homepage-ref (h)
  (let hack hack.h
    `(a (href ,(homepage hack)) ,(title hack))))

(def patch-url (hack)
  (string "http://hacks.catdancer.ws/" (tagname hack) ".patch"))

(def lib-url (hack)
  (string "http://hacks.catdancer.ws/" hack!name ".arc"))

(edef gen-index ()
  `((h1 () "Cat’s hacks")

    (table (style "margin-left: 2em;")
      (tbody ()
        ,@(map (fn (hack)
                 `(tr ()
                    (td () ,(homepage-ref hack))
                    ;; (td () ,(string hack!type))
                    (td () ,hack!short)))
               (keep (fn (hack) hack!short) hacks*))))
    (br ())
    "cat@catdancer.ws"))

;; (def get-hack (hack)
;;  (case hack!type
;;    patch
;;    `(ul ()
;;       (li ()
;;         (a (href ,(diff-url hack) target _blank) "diff against arc2"))
;;       (li () ,(github-repo hack))
;;       (li () (a (href ,(string (git-repo-http hack) "/tarball/" (aif hack!tag it 'master))) "download a tarball of arc2 with this patch applied")))

;;    lib
;;    `(ul ()
;;       ,@(if (isnt hack!name "lib")
;;             `((li ()
;;                 "With <a href=\"lib.html\">lib</a> installed:"
;;                 (br ())
;;                 ,(code "(lib \"http://hacks.catdancer.ws/" hack!name ".arc\")"))))
;;       (li ()
;;         ,(string hack!name ".arc")
;;         " (" (a (href ,(string (lib-url hack) ".txt")) "view") ")"
;;         " (" (a (href ,(lib-url hack)) "download") ")")
;;       (li () ,(github-repo hack)))))
      
(def hackof (name)
  (if (isa name 'table)
       name
       (or (find [is _!name name] hacks*) (err "no hack found with name" name))))

(= hack hackof)

(def gen-contains (h)
  (aif h!contains
        `((h3 () "Requires")
          (p ()
            "This hack needs the following patches:")
          (ul ()
            ,@(map (fn (name)
                     `(li ()
                        ,(homepage-ref name)
                        " "
                        (i () ,(esc (hack.name 'short)))))
                   it)))))

;; (def apply-hack (hack)
;;   (case hack!type
;;     patch
;;     `((h2 () "Apply This Hack to Your Arc")
;;       (p () "By using git or patch, you can incorporate this patch into your version of Arc.")

;;       (h3 () "With git")
;;       ,(code " " (pull-command hack))
;;       (p () "For example,")
;;       ,(code
;;         " $ mkdir arc
;;  $ cd arc
;;  $ git init
;;  " (pull-command hack))

;;       (h3 () "With patch")
;;       (p ()
;;         "To apply this patch to your copy of arc using the patch command, download "
;;         (a (href ,(esc (patch-url hack))) ,hack!tag ".patch")
;;         " into your Arc directory"
;;         ", and at the Unix command line inside the Arc directory, type:")
;;       ,(code " patch <" hack!tag ".patch")
;;       (p ()
;;         ,(qu "<code>patch</code>") " is a standard utility that comes with Unix.  (If you&rsquo;re running Windows, iirc <code>patch</code> comes with cygwin).")
;;       (p () "For example,")
;;       ,(code
;;         " $ wget http://ycombinator.com/arc/arc2.tar
;;  [... downloading ...]
;;  $ tar xf arc2.tar
;;  $ cd arc2
;;  $ patch <" hack!tag ".patch
;;  patching [...]
;;  $"))))

(def comment-on-hack (hack)
  (aif hack!comment
    `((h3 () "comment")
        (a (href ,it) "Comment") " in the Arc Forum.")))

(def license (hack)
  (if hack!nolicense
       nil
;;       (is hack!type 'patch)
;;        `((h3 () "license")
;;           ; (p () "The original Arc source is copyrighted by Paul Graham and Robert Morris and licensed under the Perl Foundations's Artistic License 2.0 as described in the “copyright” file in the Arc distribution.")

;;           (p () "My changes to Arc (this patch that I wrote) are in the "
;;              (a (href "http://creativecommons.org/licenses/publicdomain/") "public domain")
;;              ".")

;;           ;(p () "The <i>combination</i> of the original Arc and my changes together (what you get after you apply my patch) is also licensed under the Perl Foundations's Artistic License 2.0."))
;;           )
      (isnt hack!type 'howto)
       `((h3 () "license")
         (p () (a (href "http://creativecommons.org/licenses/publicdomain/") "public domain")))))

(def filename (hack/tag type)
  (string (tagname hack/tag) "." type))

(def path (hack/tag type)
  (string "~/git/hacks/" (filename hack/tag type)))

(def has (hack/tag type)
  (file-exists (path hack/tag type)))

(def show-file (hack/tag type)
  (if (has hack/tag type)
       `(blockquote ()
          (h4 () ,(filename hack/tag type))
          (pre ()
            ,(esc (readfilec (path hack/tag type)))))))

(def show (hack/tag)
  (trues [show-file hack/tag _] '(patch arc)))

(def needs0 (hack)
  (alref needs* (tag hack)))

(def fetch-arc0 (tag)
  (if (iso tag '(arc 2))
       (string
        "wget http://ycombinator.com/arc/arc2.tar\n"
        "tar xf arc2.tar\n"
        "cd arc2\n")
      (iso tag '(arc 3))
       (string
        "wget http://ycombinator.com/arc/arc3.tar\n"
        "tar xf arc3.tar\n"
        "cd arc3\n")))

(def fetch-arc (hack)
  (aif (find (fn ((tag version))
               (is tag 'arc))
             (needs0 hack))
        (fetch-arc0 it)))

(def needs (hack)
  (+ (needs0 hack) (list (tag hack))))

(def patches (hack)
  (keep [has _ 'patch] (needs hack)))

(def arcs (hack)
  (keep [has _ 'arc] (needs hack)))

(def sstr (xs)
  (if xs (apply string xs)))

(def prerequisites (hack)
  (aif (rem (fn ((name version)) (is name 'arc)) (needs0 hack))
        `((h3 () "prerequisites")
          (ul ()
            ,@(map (fn ((name version))
                     (let hack (hackof name)
                       `(li ()
                          (a (href ,(homepage hack))
                            ,(title hack)
                            ": "
                            ,(esc hack!short)))))
                   it)))))

(def get-patches (hack)
  (sstr
    (map (fn (tag)
           (string "wget -O - http://hacks.catdancer.ws/"
                   (filename tag 'patch)
                   " | patch"
                   "\n"))
         (patches hack))))
  
(def get-arcs (hack)
  (sstr
    (map (fn (tag)
           (string "wget http://hacks.catdancer.ws/"
                   (filename tag 'arc)
                   "\n"))
         (arcs hack))))

(def load-arcs (hack)
  (sstr
    (map (fn (tag)
           (string "(load \""
                   (filename tag 'arc)
                   "\")"
                   "\n"))
         (arcs hack))))

(def get-this (hack)
  (aif (or (fetch-arc hack)
           (get-patches hack)
           (get-arcs hack))
        (string
         (fetch-arc hack)
         (get-patches hack)
         (get-arcs hack)
         (aif (load-arcs hack)
               (string "mzscheme -m -f as.scm\n"
                       it)))))

(def get-hack (hack)
  (aif (get-this hack)
        `((h3 () "get this hack")
          ,(code it))))

(def gen (hack)
  `((a (href "/") "Cat’s hacks") ":"
    ,(if (is hack!type 'howto)
          `(h2 () ,(esc hack!short))

          `(,@(if hack!notitle
                  `((br ()) (br ()))
                  `((h1 () ,(esc (title hack)))))
            (h2 () ,hack!short)))
    ,(show hack)
    ,(aif (if (isa hack!long 'fn) (hack!long) hack!long)
           `(,@(unless hack!nodescription `((h3 () "description")))
             ,@it))
    ,(gen-bugs hack)
    ;; ,(aif (get-hack hack) `((h3 () "Get This Hack") ,it))
    ;; ,(apply-hack hack)
    ,@(aif hack!thanks
            `((h3 () "thanks")
                (p () "My thanks to " ,(string (car it)) " for help with this hack!")))
    ,@(prerequisites hack)
    ,(get-hack hack)
    ,@hack!get
    ,(comment-on-hack hack)
    ,(license hack)
    ,(aif hack!versions
       `((h3 () "versions")
         ,it))))

;; (def make-patch (tag)
;;   (if tag
;;   (let fn (string "~/git/pub/" tag)
;;     (system:string
;;       "cd ~/git/arc && "
;;       "git-diff arc2 " tag " >" fn ".patch && "
;;       "cp " fn ".patch " fn ".patch.txt"))))

;; (def make-patches ()
;;   (map [make-patch _!tag] (keep [is _!type 'patch] hacks*)))

(def copy-file (hack type)
  (system:string
   "cp ~/git/hacks/"
   (filename hack type)
   " ~/git/pub/"))

(def copy-files (hack)
  (each type '(patch arc)
    (if (has hack type)
         (copy-file hack type))))

(def copy-all-files ()
  (map copy-files hacks*))

(= css "

body {
  font-family: verdana;
  margin-left: 2em;
}

h1 {
  margin-bottom: 0.3em;
}

h2 {
  font-style: italic;
  font-weight: normal;
  font-size: larger;
  margin-top: 0;
}

h3 {
  margin-bottom: 0;
}

h4 {
  margin-top: 1em;
  margin-bottom: 0.5em;
}

p, ol, ul {
  width: 40em;
}

li {
  margin-bottom: 0.5em;
}

pre, code {
  font-family: courier;
}

pre {
  margin: 0;
}

td {
  vertical-align: top;
  padding: 0 1em 0.5em 0;
}

table.code {
  border-collapse: collapse;
}

table.code td {
  padding: 5px 1em;
  font-family: courier, monospace;
  border: 1px solid #ddd;
}

table.code td.arrow {
  border: none;
  padding: 0 1em;
  font-family: verdana;
}

table.code td.spacer {
  border: none;
  padding: 0;
}

table.foo {
  border-collapse: collapse;
}

table.foo th {
  border: none 0px;
}

table.foo td {
  vertical-align: baseline;
  padding: 1em;
  border: 1px solid #ccc;
}

")

(def mypage (title content)
  `(html ()
     (head ()
       (meta (http-equiv "Content-Type" content "text/html; charset=UTF-8"))
       (title () ,(esc title))
       ,(inline-css css))
     (body ()
       ,content)))

(def index-page ()
  (mypage "Cat’s hacks" (gen-index)))

(def doc-page (hack)
  (mypage (string:or hack!short hack!name) (gen hack)))

(def write-index-page ()
  (w/outfile f "~/git/pub/index.html"
    (disp doctype* f)
    (disp (nlhtml:index-page) f)
    (disp "\n" f))
  nil)

(def write-doc-page (hack)
  (w/outfile f (string "~/git/pub/" hack!name ".html")
    (disp doctype* f)
    (disp (nlhtml:doc-page hack) f)
    (disp "\n" f)))

(def write-doc-pages ()
  (map write-doc-page (rem [or (is _!type 'mirror) (no _!short)] hacks*)))

(def al ()
  (write-index-page)
  (write-doc-pages)
  (copy-all-files)
  'ok)
