(def code content
  `(blockquote () (pre () ,(esc (apply string content)))))

(= darc (qu "<code>.arc</code>"))

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
"))

 (obj

  name "lib"
  type 'lib
  git-repo "arc-lib"

  short "A succinct method for sharing Arc libraries."

  long

  `((h2 () "Synopsis")

    (p () "A call such as")

    ,(code "(lib \"http://catdancer.github.com/erp.arc\")")

    (p () "does the following:")

    (ol ()
      (li () "If the library file has already been loaded into Arc, nothing happens. (Program A can include libraries B and C, and library B can include library C, without C getting loaded twice).")
      (li ()
        "If the library file is already present in the <code>lib</code> directory, and it has a " ,darc " extension, it is loaded into Arc."
        (ul (style "margin-top: 0.5em;")
          (li () "As fast as <code>load</code>: No network calls are made.")
          (li () "No surprises: By design, calling <code>lib</code> by itself does not check if a newer version of the library is available.  You decide when and if you want to upgrade.")
          (li () "Easy override: put your own version of the library file in the lib directory, and it will be used instead of the remote version.")))
      (li () "If the library isn't in the <code>lib</code> directory yet, it is downloaded from the remote site, and then, if it also has a " ,darc " extension, loaded into Arc."
        (ul (style "margin-top: 0.5em;")
          (li () "No clashes: files are stored in the <code>lib</code> directory using the same directory structure as the URL.  (" ,(qu "http://catdancer.github.com/erp.arc") " is stored in " ,(qu "lib/catdancer.github.com/erp.arc") ").")
          (li () "Non-Arc files: Does your library need images or other non-Arc language files available?  Simply call <code>(lib \"http://yoururl/other-file\")</code>, and <code>other-url</code> will be available in the known location in the <code>lib</code> directory."))))

    (p (style "margin-top: 1.5em;") "<code>(lib-new)</code>")

    (p (style "margin-left: 2em;") "Prints out a list of URL's that have a new version available or have been overridden.  (That is, it prints out those URL's for which the file in the <code>lib</code> directory is different than the file at the URL).")

    (p (style "margin-top: 1.5em;") (code () "(lib-fetch " (i () "url") ")"))

    (p (style "margin-left: 2em;") "Unconditionally downloads the URL and stores it in the <code>lib</code> directory.")

    (h2 () "Rationale")

    (p () "In other languagues, sharing code is complicated: you have to package it up, and then publish your package, and users have to download and install it, and then load it their program...")

    (p () "Following Paul Graham&rsquo;s " ,(qu "<a href=\"http://paulgraham.com/power.html\">Succinctness is Power</a>") " hypothesis, I&rsquo;ve tried to imagine what could be the quickest possible way to share and use Arc code.")

    (h2 () "Prerequisites")

    (ul ()
      (li () "My <a href=\"mz.html\">mz</a> patch to Arc.")
      (li ()
        "<a href=\"http://www.gnu.org/software/wget/\">wget<a/>"
        (div (style "margin-left: 1em;")
             "Debian: <code>apt-get install wget</code>" (br ())
             "Gentoo: <code>emerge net-misc/wget"))))

  bugs
  '("Windows is not supported."
    "Relies on having <code>wget</code> installed."))

 (obj

  name "erp"
  type 'lib

  short "My favorite debug print macro."

  long

  `((p () "Consider the typical debug print statement:")

    ,(code "(prn \"foo: \" foo)")

    (p () "notice the redundancy... I want to see what value I&rsquo;m printing out, so I have to type " ,(qu "foo") " twice.")

    (p () "<code>erp</code> is a macro prints out its argument, both literally and what it evaluates to. And, it returns the result as well, so it can be inserted in the middle of some code.")

    (p () "The message is printed to stderr so that <code>erp</code> can be called from inside of a <code>defop</code>, and the message will print on Arc&rsquo;s REPL instead of appearing in the middle of the web page.")

    (p () "For example, if I&rsquo;m looking at")

    ,(code " (+ 3 (/ 4 2) 5)")

    (p () "and I&rsquo;m thinking, " ,(qu "wait, what is <code>(/ 4 2)</code> evaluating to again?") ", I stick in <code>erp</code>:")

    ,(code "
 arc> (+ 3 (erp (/ 4 2)) 5)
 (/ 4 2): 2
 10
 arc>")

    (p () "As drcode pointed out to me, by using Arc&rsquo;s colon syntax we can even avoid the extra parentheses:")

    ,(code "
 arc> (+ 3 (erp:/ 4 2) 5)
 (/ 4 2): 2
 10
 arc>")

    (p () "Why " ,(qu "<code>erp</code>") "? Well, A) it&rsquo;s short for " ,(qu "stderr print") ", and B) it&rsquo;s what I&rsquo;m usually thinking in the middle of a debug session... :-)")

))))

(def gen-bugs (hack)
  (aif hack!bugs
       `((h2 () "Bugs")
         (ul ()
           ,@(map (fn (bug)
                    `(li () ,bug))
                  it))
         ;; TODO dup /tree
         "Have fixes?  Send them to me on <a href=\"" ,(git-repo-http hack) "/tree\">GitHub</a>.")))

(def homepage (hack)
  (or hack!homepage
      (string hack!name ".html")))

(def patch-url (hack)
  (string "http://catdancer.github.com/" hack!name ".patch"))

(def diff-url (hack)
  (string "http://catdancer.github.com/" hack!name ".patch.txt"))

(def lib-url (hack)
  (string "http://catdancer.github.com/" hack!name ".arc"))

(def git-repo (hack)
  (or hack!git-repo hack!name))

(def git-repo-http (hack)
  (string "http://github.com/CatDancer/" (git-repo hack)))

(def git-repo-git (hack)
  (string "git://github.com/CatDancer/" (git-repo hack)))

(def gen-index ()
  `((h1 () "Arc Hacks")

    (table (style "margin-left: 2em;")
      (tbody ()
        ,@(map (fn (hack)
                 `(tr ()
                    (td () (a (href ,(homepage hack)) ,hack!name))
                    (td () ,(string hack!type))
                    (td () ,hack!short)))
               hacks*)))))

(def github-repo (hack)
  `(a (href ,(string (git-repo-http hack) "/tree")) "repository on GitHub"))

(def get-hack (hack)
 (case hack!type
   patch
   `(ul ()
      (li () (a (href ,(diff-url hack) target _blank) "diff against arc2"))
      (li () ,(github-repo hack))
      (li () (a (href ,(string (git-repo-http hack) "/tarball/master")) "download a tarball of arc2 with this patch applied")))

   lib
   `(ul ()
      ,@(if (isnt hack!name "lib")
            `((li ()
                "With <a href=\"lib.html\">lib</a> installed:"
                (br ())
                ,(code "(lib \"http://catdancer.github.com/erp.arc\")"))))
      (li ()
        ,(string hack!name ".arc")
        " (" (a (href ,(string (lib-url hack) ".txt")) "view") ")"
        " (" (a (href ,(lib-url hack)) "download") ")")
      (li () ,(github-repo hack)))))
      

(def apply-hack (hack)
  (case hack!type
    patch
    `((h2 () "Applying This Hack to Your Arc")
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
      ,(code "git pull " (git-repo-git hack) ".git master"))))

(def gen (hack)
  `((a (href "/") "Arc hacks") ":"
    (h1 () ,(esc hack!name))
    (p () (i () ,hack!short))
    ,hack!long
    ,(gen-bugs hack)
    ,(aif (get-hack hack) `((h2 () "Get This Hack") ,it))
    ,(apply-hack hack)))

(def make-patch (name)
  (let fn (string "~/git/catdancer.github.com/" name)
    (system:string
      "cd ~/git/" name " && "
      "git-diff arc2 HEAD >" fn ".patch && "
      "cp " fn ".patch " fn ".patch.txt")))

(def make-patches ()
  (map [make-patch _!name] (keep [is _!type 'patch] hacks*)))

(def copy-lib (name)
  (system:string
   "cp ~/git/" name "/* ~/git/catdancer.github.com/")
  (system:string
   "cd ~/git/catdancer.github.com; cp " name ".arc " name ".arc.txt"))

(def copy-libs ()
  (map [copy-lib _!name] (keep [is _!type 'lib] hacks*)))

(= css "

body {
  font-family: verdana;
  margin-left: 2em;
}

p, ol {
  width: 40em;
}

li {
  margin-bottom: 0.5em;
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
  (mypage "Arc Hacks" (gen-index)))

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
  (copy-libs)
  'ok)
