(edef code content
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

    (p () "Following Paul Graham&rsquo;s " ,(qu "<a href=\"http://paulgraham.com/power.html\">Succinctness is Power</a>") " hypothesis, I tried to imagine what could be the quickest possible way to share and use Arc code.")

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

    (p () "Why " ,(qu "<code>erp</code>") "? Well, A) it&rsquo;s short for " ,(qu "stderr print") ", and B) it&rsquo;s what I&rsquo;m usually thinking in the middle of a debug session... :-)")))

 
 (obj
  name "extend"
  type 'lib

  short "Extend Arc functions"

  long

  `((p () (code () "(extend <i>name</i> <i>label</i> <i>test</i> <i>replacement</i>)"))

    (p () "Extends the function <i>name</i>.  Replaces <i>name</i> with a new definition so that when <i>name</i> is called later, <i>test</i> is first called with the same arguments.  If <i>test</i> returns true, the <i>replacement</i> function is called instead of the original definition of <i>name</i>.  If <i>test</i> returns false, the original definition of <i>name</i> is called as if the function hadn't been extended.")

    (p () "For example,")

    ,(code "
 (extend + table
   (fn (x . _) (is (type x) 'table))
   (fn ts (listtab (apply + (map tablist ts)))))

 arc> (+ (obj a 1) (obj b 2))
 #hash((a . 1) (b . 2))
")

    (p () "You can extend a function several times and the extensions will be chained together.  Each extension in turn (starting with the last defined) will be asked if it wants to handle this call, and if its test function returns false, the next extension is tried, and then finally the original function is called if none of the extensions step in.")

    (p () "The label is used during development to distinguish between extensions.  If you call <code>extend</code> again with the same label on the same function name, it replaces the extension on the function instead of adding it to the function&rsquo;s chain.  As you develop an extension this avoids having your earlier, buggy implementations left on the extension chain.")

    (h2 () "Rationale")

    (p () "Many languages and libraries offer ways to modify or extend their behavior such as option lists, registering callbacks, or specializing on types.  These mechanisms often look convenient, but in practice I&rsquo;ve found that, at least for me, the designers often haven&rsquo;t anticipated the kind of modification that I need to make.  I'm left with either awkwardly trying to shoehorn the API to do want I need, or hack the source.  Hacking the source is made ironically difficult, because along with doing whatever useful thing that I want the language or library to do for me, the code is obfuscated with a layer of option parsing / callback mechanisms / class hierarchies etc.")

    (p () "As a specific example, I&rsquo;ve used a number of web servers in developing web applications.  None of them do everything I need, but I&rsquo;ve found Arc the easiest to get to do what I need, because the source is so easy to hack, so I just go in and make it do whatever it is.")

    (p () "The caveat comes when I want to share my hack with others.  I can share a patch file, but patch files aren&rsquo;t easily composable.  If two patch files modify the same area of code you&rsquo;ll get a patch conflict that has to be resolved manually.")

    (p () "<code>extend</code> is one possible answer when a hack can be implemented by changing the behavior of a function.  Like patching the source, you do not need to do anything to the original code to make it extendable.  Unlike patches, function extensions are composable.")

    (p () "Of course only some Arc hacks can be represented as changing a function (<code>extend</code> does nothing to help with hacking macros, as just one example), so <code>extend</code> is not a general purpose extension mechanism.")

    (p () "An interesting gray area is cases where Arc could be usefully extended by <code>extend</code> if particular functionality was available as a function.  I&rsquo;ll share two examples, the first if the function <code>respond</code> in Arc&rsquo;s web server were factored into two functions, and the second if Arc&rsquo;s compiler were made available as an Arc function.")

    (h2 () "Examples")

    (h3 () "Extending Arc&rsquo;s web server")

    (p () "Suppose we wanted to treat an op that was a number specially, so that instead of " ,(qu "http://mysite.com/item?id=1234") " we could use " ,(qu "http://mysite.com/1234") ".")

    ,(code "
 (def digit (c)
   (<= #\\0 c #\\9))

 (def isid (op)
   (all digit (string op)))
")

    (p () "The point in srv.arc where it figures out which function to call given the URL is in the function <code>respond</code>:")

    ,(code "
 (def respond (str op args cooks ip)
   (w/stdout str
     (aif (srvops* op)
           (let req (inst 'request 'args args 'cooks cooks 'ip ip)
             (if (redirector* op)
                 (do (prn rdheader*)
                     (prn \"Location: \" (it str req))
                     (prn))
                 (do (prn header*)
                 ...
")

    (p () "So let&rsquo;s make our own function to handle the response in the case where the URL is a number:")

    ,(code "
 (def respond-id (str op args cooks ip)
   (w/stdout str
     (prn header*)
     (prn \"this is the page for the item with id \" op)))
")

    (p () "And a function to decide if we&rsquo;re going to handle this response:")

    ,(code "
 (def id-test (str op args cooks ip)
   (isid op))
")

    (p () "Extending <code>respond</code>:")

    ,(code "
 (extend respond id id-test respond-id)
")

    (p () "And that&rsquo;s all we need to implement our extension:")

    ,(code "
 $ curl http://localhost:8080/1234
 this is the page for the item with id 1234
")
    
    (p () "Notice however how our implementation of <code>respond-id</code> needs to set up <code>stdout</code>, which is done for us if we&rsquo;re using a <code>defop</code>, and we&rsquo; not getting a <code>req</code> object, which is passed into a <code>defop</code> for us.  This is because Arc&rsquo;s implementation of <code>respond</code> is doing two things: setting up to handle the request and creating the <code>req</code> object, and figuring out which function to call to handle the request.  If Arc&rsquo;s implementation were factored into two functions, something like this:")

    ,(code "
 (def respond (str op args cooks ip)
   (w/stdout str
     (let req (inst 'request 'args args 'cooks cooks 'ip ip 'op op 'str str)
       (choose-response req))))

 (def choose-response (req)
   (aif (srvops* req!op)
         (if (redirector* req!op)
         ...
")

    (p () "then our extension becomes even simpler:")

    ,(code "
 (def id-test (req)
   (isid req!op))

 (def respond-id (req)
   (prn header*)
   (prn)
   (prn \"this is the page for the item with id \" req!op))

 (extend choose-response id id-test respond-id)
")

    (h3 () "Extending the Arc compiler")

    (p () "Arc&rsquo;s MzScheme implementation of <code>ac</code> in <code>ac.scm</code> looks like:")

    ,(code "
 (define (ac s env)
   (cond ((string? s) (string-copy s))
         ((literal? s) s)
         ((eqv? s 'nil) (list 'quote 'nil))
         ...
")

    (p () "if we rename this to <code>ac-impl</code>:")

    ,(code "
 (define (ac-impl s env)
   (cond ((string? s) (string-copy s))
         ((literal? s) s)
         ...
")

    (p () "and make an Arc function <code>arc-ac</code> which is implemented by this:")

    ,(code "
 (xdef 'arc-ac ac-impl)
")

    (p () "and have the MzScheme <code>ac</code> procedure call Arc&rsquo;s <code>arc-ac</code>:")

    ,(code "
 (define (ac s env)
   ((namespace-variable-value '_arc-ac) s env))
")

    (p () "The Arc compiler is now available in Arc.  Normally when an Arc variable refers to an MzScheme procedure, changing the variable doesn't effect anything in MzScheme, but since we're arranged for MzScheme to call Arc&rsquo;s <code>arc-ac</code> function, we can change the behavior of Arc&rsquo;s compiler.  We do need to keep in mind that despite being an Arc function, <code>arc-ac</code> is passed MzScheme values and needs to return an MzScheme value.")

    (p () "To prove that we can really change Arc&rsquo;s compiler, let&rsquo;s try replacing it with an obstinate one:")

    ,(code "
arc> (def arc-ac (s env) (mz ''nope))
#<procedure: arc-ac>
arc> 1
nope
arc> (+ 3 (/ 10 4))
nope
arc> (quit)
nope
arc> ^C
")

    (p () ("It worked!  (I&rsquo;m using my <a href=\"mz.html\">mz</a> patch to let me easily return an MzScheme value)."))

    (p () ("Here&rsquo;s an extension to Arc&rsquo;s compiler so that reading an end-of-file character (^D in Unix) exits Arc:"))

    ,(code "
 (extend arc-ac eof
   (fn (s env) (mz (eof-object? s)))
   (fn (s env) (quit)))

 arc> ^D
 $
")

    ))

 (obj
  name "json"
  type 'lib

  short "alpha release of a JSON parser / generator"

  long

  `((p () "<a href=\"http://json.org/\">JSON</a> is a lightweight data-interchange format.  It is a subset of JavaScript, and so is especially popular for web applications.")

    ,(code "
 arc> (prn:tojson `(1 \"a\" ,(obj x 'null y 'true)))
 [1,\"a\",{\"y\":true,\"x\":null}]

 arc> (fromjson \"[true,false,null,[],42]\")
 (t nil nil nil \"42\")
")
    )

    bugs
    '("fromjson returns numbers as an unparsed string."
      "Whitespace is not parsed."
      "fromjson does not distinguish between <code>false</code>, <code>null</code>, and the empty array, if that&rsquo;s something you need for your application."
      "tojson does not recognize non-integer numbers."
      "Lots of duplicate and ugly code in the implementation."
      )

    )

 ))

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
                ,(code "(lib \"http://catdancer.github.com/" hack!name ".arc\")"))))
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

(def license (hack)
  `((h2 () "License")
    (p () (a (href "http://creativecommons.org/licenses/publicdomain/") "public domain"))))

(def gen (hack)
  `((a (href "/") "Arc hacks") ":"
    (h1 () ,(esc hack!name))
    (p () (i () ,hack!short))
    ,hack!long
    ,(gen-bugs hack)
    ,(aif (get-hack hack) `((h2 () "Get This Hack") ,it))
    ,(apply-hack hack)
    ,(license hack)))

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

(def al ()
  (write-index-page)
  (write-doc-pages)
  (make-patches)
  (copy-libs)
  'ok)
