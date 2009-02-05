(def code content
  `(blockquote () (pre () ,(esc (apply string content)))))

(= hacks* (list

 (obj

  name "arc"
  type 'mirror
  homepage "http://github.com/arcmirror/arc/tree/master"

  short "An unmodified mirror of Paul Graham&rsquo;s Arc releases.")

 (obj

  name "mz"
  type 'patch
  git-repo "arc-mz-patch"

  short "Allows easy access to the underlying MzScheme language that Arc is written in."

  long

  `((p () "This hack introduces an " ,(qu "<code>mz</code>") " syntax form into Arc.  The argument to <code>mz</code> is passed through unchanged to MzScheme when the Arc expression is compiled into MzScheme. For example, to call the MzScheme procedure " ,(qu "<code>current-seconds</code>") ", you can say:")

    ,(code "
  arc> (mz (current-seconds))
  1233715389
")

    (p () "With Arc&rsquo;s colon syntax, this can also be written as:")

    ,(code "
arc> (mz:current-seconds)
1233715437
")

    (p () "I chose to call the syntax " ,(qu "<code>mz</code>") " so that visually, " ,(qu "<code>mz:current-seconds</code>") " looks like " ,(qu "call MzScheme&rsquo;s <code>current-seconds</code> procedure") ".")

    (p () "Note however, that by itself <code>mz</code> does not convert between MzScheme and Arc data types.  For example, if an MzScheme procedure returns a boolean, you&rsquo;ll get an MzScheme <code>#t</code> or <code>#f</code> boolean, not an Arc <code>t</code> or <code>nil</code> boolean.")

    ,(code "
arc> (mz:port? 4)
#f
")))

 (obj

  name "date"
  type 'patch
  git-repo "arc-date-patch"

  short "Cross-platform implementation of Arc&rsquo;s date function."

  long

  `((p () "In arc2 the <code>date</code> function is implemented by running the operating system&rsquo;s <code>date</code> command.  Unfortunately the <code>date</code> command in different operating systems take different arguments, and so the <code>date</code> function in arc2 only works with operating systems where the <code>date</code> command takes the <code>-u</code> and <code>-r</code> arguments.")

    (p () "This patch implements Arc&rsquo;s <code>date</code> using MzScheme&rsquo;s <code>date.ss</code> library, and so works in any operating system that MzScheme runs in in.")
))

 (obj

  name "atomic-fix"
  type 'patch
  git-repo "arc-atomic-fix"

  short "Fixes arc2&rsquo;s atomic macro to work in the presence of exceptions."

  long

  `((p () "arc2 has a bug where calls to <code>atomic</code> will stop being atomic after an exception is thrown inside of a call to <code>atomic</code>.  For example, after:")

    ,(code "(errsafe (atomic (/ 1 0)))")

    (p () "further calls to <code>atomic</code> will no longer be atomic.  This patch fixes the bug.")))

 (obj

  name "exit-on-eof"
  type 'patch
  git-repo "arc-exit-on-eof"

  short "Patches Arc so that an eof (^D in Unix) at the command prompt will exit Arc."

  long
  (code "
$ mzscheme -m -f as.scm
Use (quit) to quit, (tl) to return here after an interrupt.
arc> ^D
$
"))))

(def homepage (hack)
  (or hack!homepage
      (string hack!name ".html")))

(def patch-url (hack)
  (string "http://catdancer.github.com/" hack!name ".patch"))

(def diff-url (hack)
  (string "http://catdancer.github.com/" hack!name ".patch.txt"))

(def git-repo-http (hack)
  (string "http://github.com/CatDancer/" hack!git-repo))

(def git-repo-git (hack)
  (string "git://github.com/CatDancer/" hack!git-repo))

(def gen-index ()
  `((h1 () "Cat Dancer&rsquo;s Hacks")

    (table (style "margin-left: 2em;")
      (tbody ()
        ,@(map (fn (hack)
                 `(tr ()
                    (td () (a (href ,(homepage hack)) ,hack!name))
                    (td () ,(string hack!type))
                    (td () ,hack!short)))
               hacks*)))))

(def gen (hack)
  `((a (href "/") "Cat Dancer&rsquo;s hacks") ":"
    (h1 () ,(esc hack!name))
    (p () (i () ,hack!short))
    ,hack!long
    (h2 () "Get This Hack") 
    (ul ()
      (li () (a (href ,(diff-url hack) target _blank) "diff against arc2"))
      (li () (a (href ,(string (git-repo-http hack) "/tree/master")) "repository on GitHub"))
      (li () (a (href ,(string (git-repo-http hack) "/tarball/master")) "download a tarball of arc2 with this patch applied"))
      )
    (h2 () "Applying This Hack to Your Arc")
    (p () "By using patch or git, you can incorporate this patch into your version of Arc.")
    (h3 () "With patch")
    (p ()
      "To apply this patch to your copy of arc using the patch command, download "
      (a (href ,(esc (patch-url hack))) ,hack!name ".patch")
      " into your Arc directory"
      ", and type:")
    ,(code "patch <" hack!name ".patch")
    (h3 () "With git")
    (p ()
       "To apply this patch using git, start with a git repository containing arc2 or the version of Arc that you want to patch.  Then in the git working directory, type:")
    ,(code "git pull " (git-repo-git hack) ".git master")))

(def make-patch (name)
  (let fn (string "~/git/catdancer.github.com/" name)
    (system:string
      "cd ~/git/" name " && "
      "git-diff arc2 HEAD >" fn ".patch && "
      "cp " fn ".patch " fn ".patch.txt")))

(def make-patches ()
  (map [make-patch _!name] (keep [is _!type 'patch] hacks*)))

(= css "

body {
  font-family: verdana;
  margin-left: 2em;
}

p {
  width: 40em;
}

pre, code {
  font-family: courier;
}

td {
  vertical-align: top;
  padding: 0 1em 0.5em 0;
}

")

(def mypage (title content)
  `(html ()
      (head ()
         (title () ,(esc title))
         ,(inline-css css))
       (body ()
         ,content)))

(def index-page ()
  (mypage "Cat Dancer's Hacks" (gen-index)))

(def doc-page (hack)
  (mypage hack!name (gen hack)))

(def write-index-page ()
  (w/outfile f "~/git/catdancer.github.com/index.html"
    (disp doctype* f)
    (disp (html:index-page) f)
    (disp "\n" f))
  nil)

(def write-doc-page (hack)
  (w/outfile f (string "~/git/catdancer.github.com/" hack!name ".html")
    (disp doctype* f)
    (disp (html:doc-page hack) f)
    (disp "\n" f)))

(def write-doc-pages ()
  (map write-doc-page (rem [is _!type 'mirror] hacks*)))

(def all ()
  (write-index-page)
  (write-doc-pages)
  (make-patches)
  "OK")
