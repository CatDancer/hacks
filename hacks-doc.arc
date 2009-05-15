(edef code content
  `(blockquote () (pre () ,(esc (apply string content)))))

(= darc (qu "<code>.arc</code>"))

(def indent xs
  `(div (style "margin-left: 2em") ,@xs))

(= hacks* (list

 (obj
  name "sharing-hacks"
  type 'howto
  short "Sharing Arc hacks"
  comment "http://arclanguage.org/item?id=9137"

  long
  `((h3 () "Hacking and patches")

    (p () "Arc is a highly hackable language, so we can expect that programmers will create many Arc hacks.  Some will be good, some bad, some experimental, some very interesting.  Some hacks may be highly useful for a particular project but a bad idea for Arc in general.")

    (p () "As an Arc programmer, I’d like to be able to easily use hacks that other hackers create.  And, to be able to get that hack without getting a lot of other hacks that I don’t want or don’t need.  If I like a hack to Arc, or want to use it for a particular project, I’d like to be able to apply just that patch to Arc, without having to get a lot of other hacks as well.")

    (p () "As someone who would like to use other people’s hacks, for me the ideal situation would be if every hack were available as a minimal set of differences from Arc.")

    (p () "This is a rather unusual notion, since most software is distributed in releases, with each release incorporating a bunch of patches.  To work on the release, programmers will check in patches to a development branch.  When everything is working, the branch will be tagged (“version 1.52”) and released.")

    (p () "Unless special care is taken to produce a clean patch series, this process mushes hacks together.  I’ll be working on hack A, and check in a patch A0, and then other hacks B, C, D, E, and F will get checked in, and then I’ll check some more patches A1 and A2 which finish up hack A.  Now it’s tedious to pull out just hack A without getting the rest.")

    (p () "There is one common example where programmers do work at creating a “clean” patch set: when they are submitting work to a project’s coordinator, and want to make it easy for the coordinator to understand and accept the patches.")

    (p () "But this common scenario has a middleman: the coordinator who is collecting patches from developers and creating releases.  I, the programmer using the code, gets the patches from the developers through the coordinator.  The coordinator is deeply knowledgeable about the hairy internal details of the software and makes sure that the submitted patches don’t unintentionally break things.")

    (p () "What if we don’t need a middleman?  Arc today is remarkably free of “hairy internal details”.  One of the results of refining code down to its most succinct representation is that you aren’t left with a lot of complicated structure that you need to be a guru to figure out.")

    (p () "What if it were as easy and comfortable to choose which patches you wanted in your Arc as it is in other languages to choose which libraries you wanted to use?")

    (p () "I suspect there may be some unexpected benefits.  As one example, when code just does what is needs to do like <code>(do (a) (b) (c))</code> it’s easy to see what it’s doing.  But then some people need different things and so we start getting configuration options like <code>(do (if config*!a (a)) (if config*!b (b)) ...)</code>.  I’ve seen libraries where there is more code dealing with configuration options specifying what to do then there is code to do the actual thing that the library is supposed to do.  What if the code was so clear and patches so easy that it would be as easy to specify a patch to set the code to <code>(do (a) (c))</code> as it would be to write a configuration file?")

    (h3 () "Using git")

    (p () "I’ve been playing around with git, wondering if git was a good choice for sharing Arc hacks, and if so, which git entity (repositories, branches, tags...) would be best to use for one hack.  From what I can tell so far, it looks like tags work well.")

    (p () "Suppose, for example, that you happened to want arc2 with my date and atomic fixes, my patch to read and write Arc tables, and nothing else that wasn’t needed for those hacks.  Here’s how to do it with git (git’s output is not shown.  Also, this assumes that you’re using my commit of arc2; see the next section if you’re starting with a different commit of arc2):")

    ,(code "
 $ git clone git://github.com/CatDancer/arc.git
 $ cd arc
 $ git checkout arc2
 $ git merge arc2.date0
 $ git merge arc2.atomic-fix0
 $ git merge arc2.table-reader-writer0
")

    (p () "Your working directory will now contain a version of arc2 with those patches applied.")

    (p () "My naming convention for these tags is that the first part (“arc2”) is what is being patched, the second part is the name of the hack, and the final number is the version of the hack.  Each hack contains the minimal number of changes needed to patch arc2 to implement just that hack, and nothing more.")

    (p () "Some hacks do depend on other hacks, so the git commands above will have pulled in some other hacks as well.  The <code>--decorate</code> option to <code>git-log</code> will print out tags that point to included commits:")

    ,(code "
 $ git-log --decorate
 ...
 commit bef6020695b2a4e7721e09d6833bbc2c1f512eae (refs/tags/arc2.table-reader-writer0)
 Author: Cat Dancer <cat@catdancer.ws>
 Date:   Sun Apr 12 15:00:35 2009 -0400
 ...
 commit 1f2243319651f5797ecb3f4e0166bfd5751af3b1 (refs/tags/arc2.scheme-values0)
 ...
")

    (p () "To get just the tag names, the <code>%d</code> format string prints the “decorate” value:")

    ,(code "
 $ git log --pretty=format:%d


 (refs/tags/arc2.table-reader-writer0)

 (refs/tags/arc2.scheme-values0)
 (refs/tags/arc2.list-writer0)
 (refs/tags/arc2.date0)
 (refs/tags/arc2.atomic-fix0)
 (refs/tags/arc2, refs/remotes/origin/master, refs/remotes/origin/HEAD, refs/heads/master)

 ")

    (p () "(The blank lines are the merge commits that don’t have any tags pointing to them).  This output in turn can be made easier to read by pulling out just the tags:")

    ,(code "
 $ git log --pretty=format:%d | perl -ne 'm.refs/tags/([^),]+). && print \"$1\\n\"'
 arc2.table-reader-writer0
 arc2.scheme-values0
 arc2.list-writer0
 arc2.date0
 arc2.atomic-fix0
 arc2
")

    (p () "Now we can easily see that the “scheme-values” and “list-writer” hacks were dependencies and got pulled in as well.")

    (p () "Why tags instead of branches?  I could have a “table-reader-writer” branch which contained the latest version of that hack, and I might do that for some of my larger hacks where I’m actually going through multiple revisions.  However, we need tags anyway to keep track of which version of a patch we have (since version 1 of hack A might be based on version 4 of hack B, while version 2 of hack A is based on version 6 of hack B).  Since branches evolve over time, git has extra machinery to keep track of branches and to allow local branches to track remote branches, etc., a complexity which isn’t needed if all you want is to grab version 0 of the arc2 date patch.")

    (p ()
       "At the moment I have around twenty hacks to Arc checked in to my "
       (a (href "http://github.com/CatDancer/arc/tree/master") "git repository on github")
       ", each one independently accessible as a separate tag.")

    (p () "Many of these hacks are tiny.  For example, arc2.testify-iso0 lets you pass in a list as the test argument to the functions that use testify:")

    ,(code "
 arc> (rem '(c 3) '((a 1) (b 2) (c 3) (d 4)))
 ((a 1) (b 2) (d 4))
")

    (p () "the patch adds one letter to the Arc source code, changing a call to <code>is</code> to <code>iso</code>:")

    ,(code "
  (def testify (x)
 -  (if (isa x 'fn) x [is _ x]))
 +  (if (isa x 'fn) x [iso _ x]))
 ")

    (p ()
      "You can see a pretty colored version of the commit on "
      (a (href "http://github.com/CatDancer/arc/commit/a1753d2fc5dc9cb841b3172e2b42f9a15be6bc65") "github")
      ".")

    (h3 () "Dealing with different ancestor commits")

    (p () "The example above of merging patches went very smoothly, but it did assume that you were starting with my commit of arc2.  Suppose instead you started with your own:")

    ,(code "
 $ wget http://ycombinator.com/arc/arc2.tar
 $ tar xf arc2.tar
 $ cd arc2
 $ git init
 $ git add .
 $ git commit -m 'initial version'
")

    (p () "Now you can fetch a patch of mine:")

    ,(code "
 $ git fetch git://github.com/CatDancer/arc.git tag arc2.date0
")

    (p () "But now if you try to merge the patch you’ll get conflicts:")

    ,(code "
 $ git merge arc2.date0
 Auto-merging ac.scm
 CONFLICT (add/add): Merge conflict in ac.scm
 Auto-merging arc.arc
 CONFLICT (add/add): Merge conflict in arc.arc
 Automatic merge failed; fix conflicts and then commit the result.
")

    (p () "The problem is that git knows that arc2.date0 is a patch to my commit of arc2, but it doesn’t know that your checkin of arc2 can be treated the same as my commit.")

    (p () "There’s an easy fix.  First let’s get rid of the failed merge and revert back to your checkin of arc2 that you had before:")

    ,(code "
 $ git reset --hard
")

    (p () "By “merging” my arc2 into your checkin of arc2, git will know that they don’t conflict.")

    ,(code "
 $ git merge arc2
")

    (p () "None of the files actually change in this merge commit, since after all your checkin of arc2 and my commit of arc2 are the same.  But now the merge of my patch goes smoothly:")

    ,(code "
 $ git merge arc2.date0
")

    ))
 
 (obj
   name "emacs-utf8"
   type 'howto
   short "How to convince Emacs to save .arc files in UTF-8"
   
   long
   `((p () "MzScheme supports Unicode and defaults to reading and writing files in the Unicode UTF-8 encoding, so you can conveniently use Unicode characters in both strings and symbols.")

     (p ()
       "UTF-8 is a superset of ASCII, so an ASCII file can be read in as a UTF-8 document without any special translation.  If a Unicode document contains only ASCII characters, then when it is written out as a UTF-8 file it will be a plain ASCII file.")

     (p ()
       "However, if you use Emacs as your editor, there was some ancient file archive format that had an "
       ,(qu "arc") " extension, so by default Emacs will save <code>.arc</code> files without any translation from Emacs&rsquo; internal representation of Unicode characters.  This means that while you can easily type or copy Unicode characters into your Emacs buffer, when you save your file the characters will turn into garbage.")

     (p () "Add this to your <code>.emacs</code> file to have <code>.arc</code> files saved in UTF-8:")

     ,(indent
        `((pre ()
            "(setq auto-coding-alist\n"
            "  (cons '(\"\\\\.arc\\\\'\" . utf-8) auto-coding-alist))\n")))
      ))

; (obj
;
;  name "arc"
;  type 'mirror
;  homepage "http://github.com/arcmirror/arc/tree/master"
;
;  short "An unmodified mirror of Paul Graham&rsquo;s Arc releases.")

 (obj
  name "table-reader-writer"
  type 'patch
  git-repo "arc"
  tag "arc2.table-reader-writer0"
  comment "http://arclanguage.org/item?id=9131"

  contains '("scheme-values" "list-writer")

  short "Reader / writer for Arc tables"

  long

  `((p ()
      "This patch to Arc adds a reader and writer for Arc tables so that they are printed out in a way that they can be read back in.")

    (p ()
      "Although this patch implements a particular syntax for table literals (a simple unstructed list of keys and values within curly braces), my main goal was implementing the reader / writer part; the patch can easily be hacked to some other syntax if you prefer another.")

    ,(code " arc> (obj \"Boston\" 'bos \"San Francisco\" 'sfo \"Paris\" 'cdg)
 {\"San Francisco\" sfo \"Paris\" cdg \"Boston\" bos}
 arc> {\"San Francisco\" sfo \"Paris\" cdg \"Boston\" bos}
 {\"San Francisco\" sfo \"Paris\" cdg \"Boston\" bos}")

    (p ()
      "Unlike tables read using MzScheme’s <code>#hash((...))</code> syntax, tables read in by this reader can be modified.")))

 (obj
  name "mz"
  type 'patch
  git-repo "arc"
  tag "arc2.mz0"
  comment "http://arclanguage.org/item?id=8719"
  view t

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
  git-repo "arc"
  tag "arc2.date0"

  short "Cross-platform implementation of Arc&rsquo;s date function."

  long

  `((p () "In arc2 the <code>date</code> function is implemented by running the operating system&rsquo;s <code>date</code> command.  Unfortunately the <code>date</code> command in different operating systems take different arguments, and so the <code>date</code> function in arc2 only works with operating systems where the <code>date</code> command takes the <code>-u</code> and <code>-r</code> arguments.")

    (p () "This patch implements Arc&rsquo;s <code>date</code> using MzScheme&rsquo;s <code>date.ss</code> library, and so works in any operating system that MzScheme runs in in.")
))

 (obj

  name "atomic-fix"
  type 'patch
  git-repo "arc"
  tag "arc2.atomic-fix0"
  short "Fixes arc2&rsquo;s atomic macro to work in the presence of exceptions."

  long

  `((p () "arc2 has a bug where calls to <code>atomic</code> will stop being atomic after an exception is thrown inside of a call to <code>atomic</code>.  For example, after:")

    ,(code "(errsafe (atomic (/ 1 0)))")

    (p () "further calls to <code>atomic</code> will no longer be atomic.  This patch fixes the bug.")))

 (obj

  name "exit-on-eof"
  type 'patch
  git-repo "arc"
  tag "arc2.exit-on-eof0"
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
  comment "http://arclanguage.org/item?id=8889"

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

    ,(indent "Prints out a list of URL's that have a new version available or have been overridden.  (That is, it prints out those URL's for which the file in the <code>lib</code> directory is different than the file at the URL).")

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
   name "byte"
   type 'lib
   git-repo "hacks"

   ;short "A small bit of 8-bit byte support in Arc"

   ;long
   #;`((p ()
       "In MzScheme, strings contain Unicode characters and "
       (a (href "http://download.plt-scheme.org/doc/352/html/mzscheme/mzscheme-Z-H-3.html#node_sec_3.6")
         "byte strings")
       " are used for arbitrary 8-bit byte data.  This hack adds a little bit of support for byte strings in Arc (what I&rsquo;m currently using in my own code).")
     (p () (code () "(instring s)"))

     ,(indent
        `("Arc&rsquo;s " (code () "instring") " function (which takes a string and returns an input port reading from that string) is extended to accept a byte string argument, and so Arc&rsquo;s " (code () "w/instring") " and " (code () "fromstring") " will as well."))
     
      (p () (code () "(bytestring a b c ...)"))

      ,(indent
         `((p () "The arguments are converted to byte strings, and the resulting byte strings are concatenated together, and the resulting byte string is returned.")
           (p () "Arguments that are already byte strings are simply concatenated unchanged.  Other values are first converted to an Arc string with <code>string</code>, and then the Unicode characters in the Arc string are converted to a byte string using the Unicode UTF-8 encoding.")))

      ))

 (obj name "perl" type 'lib git-repo "hacks")

 (obj
  name "erp"
  type 'lib
  comment "http://arclanguage.org/item?id=8726"

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
  comment "http://arclanguage.org/item?id=8895"

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
  comment "http://arclanguage.org/item?id=8896"

  short "JSON reader / writer"

  long

  `((p () "<a href=\"http://json.org/\">JSON</a> is a lightweight data-interchange format.  It is a subset of JavaScript, and so is especially popular for web applications.")

    ,(code "
 arc> (prn:tojson `(1 \"a\" ,(obj x 'null y 'true)))
 [1,\"a\",{\"y\":true,\"x\":null}]

 arc> (fromjson \"[true,false,null,[],42]\")
 (t nil nil nil \"42\")
")
    )

    versions
    `(ul ()
       (li () "v2: removed an unnecessary dependency on the mz patch")
       (li () "v1: fixed encoding of control characters")
       (li () "v0: initial version"))
         
    bugs
    '("fromjson returns numbers as an unparsed string."
      "Whitespace is not parsed."
      "fromjson does not distinguish between <code>false</code>, <code>null</code>, and the empty array, if that&rsquo;s something you need for your application."
      "tojson does not recognize non-integer numbers."
      "Lots of duplicate and ugly code in the implementation."
      )

    )

 (obj
  name "scheme-values"
  type 'patch
  git-repo "arc"
  tag "arc2.scheme-values0"
  view t

  short "Allows Scheme values to pass through the Arc compiler.")

 (obj
  name "list-writer"
  type 'patch
  git-repo "arc"
  tag "arc2.list-writer0"

  short "A writer for Arc lists."

  long
  (fn ()
    `((p ()
        "<code>arc2</code> writes Arc lists by converting them to Scheme lists and printing them using the Scheme writer.  By implementing a writer for Arc values we can build upon this patch to customize the output of Arc values.  The " ,(homepage-ref "table-reader-writer") " patch does this for Arc tables.")

      (p ()
        "By itself this patch is supposed to produce the same output as <code>arc2</code> does.  (If it doesn’t, that would be a bug)."))))

 (obj
  name "load-rename"
  title "load-w/rename"
  type 'patch
  git-repo "arc"
  tag "arc2.load-rename0"

  short "Load an Arc source code file with renames"

  long
  `((p () "thaddeus wanted to use my JSON library, but it defined a function called “alt” which conflicted with another library he was using that had a function with the same name.")

    (p () "Conventionally, libraries are supposed to carefully hide away their internals to avoid just this kind of conflict.  There’s a couple of problems with this approach though:")
    
    (ul ()
      (li () "The library author doesn’t <i>know</i> how the library is going to be used, so the effort made to avoid conflicts is speculative: time may be spent hiding a function which as it turns out never would have caused a conflict in the future, or if the function <i>hadn’t</i> been hidden away it might have turned out to be useful to other code in ways that the library author hadn’t thought of.")
      (li () "Even after going to the extra work and attendent code complication of hiding library internals, the library may <i>still</i> be making names visible which conflict with some future use of the library."))

    (p ()
      "Thus the problem with the conventional approach is that the library author is being asked to take responsibility for avoiding conflicts at the time the library is written, when it is impossible to know what actually needs to be done to avoid conflicts because the actual conflicts can’t be known until the library is used with other software.")

    (p ()
      "Whether or not the library author has attempted to avoid conflicts by hiding library internals, if a conflict does occur then it falls upon the programmer using the library to resolve the conflict.")

    (p ()
      "One approach to resolve the conflict is to simply rename the offending function or macro in the library, giving it a name that doesn't conflict with the other code being used.")

    (p ()
      "Naturally if there’s some renaming that needs to be done, we’d prefer to let the computer do it for us rather than tediously having to go through the library source code doing the renaming by hand.")

    ,(code "
 (load-w/rename \"json.arc\" '((alt json-alt)))
")

    ))

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

(def homepage-ref (h)
  (let hack hack.h
    `(a (href ,(homepage hack)) ,(or hack!title hack!name))))

(def patch-url (hack)
  (string "http://catdancer.github.com/" hack!tag ".patch"))

(def diff-url (hack)
  (string "http://catdancer.github.com/" hack!tag ".patch.txt"))

(def lib-url (hack)
  (string "http://catdancer.github.com/" hack!name ".arc"))

(def git-repo (hack)
  (or hack!git-repo hack!name))

(def git-repo-http (hack)
  (string "http://github.com/CatDancer/" (git-repo hack)))

(def git-repo-git (hack)
  (string "git://github.com/CatDancer/" (git-repo hack)))

(edef gen-index ()
  `((h1 () "Cat’s hacks")

    (table (style "margin-left: 2em;")
      (tbody ()
        ,@(map (fn (hack)
                 `(tr ()
                    (td () ,(homepage-ref hack))
                    (td () ,(string hack!type))
                    (td () ,hack!short)))
               (keep (fn (hack) hack!short) hacks*))))
    (br ())
    "cat@catdancer.ws"))

(def github-repo (hack)
  `(a (href ,(string (git-repo-http hack) "/tree" (aif hack!tag (string "/" it))))
     "repository on GitHub"))

(def get-hack (hack)
 (case hack!type
   patch
   `(ul ()
      (li ()
        (a (href ,(diff-url hack) target _blank) "diff against arc2"))
      (li () ,(github-repo hack))
      (li () (a (href ,(string (git-repo-http hack) "/tarball/" (aif hack!tag it 'master))) "download a tarball of arc2 with this patch applied")))

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
      
(def hack (name)
  (if (isa name 'table)
       name
       (or (find [is _!name name] hacks*) (err "no hack found with name" name))))

(def gen-contains (h)
  (aif h!contains
        `((h2 () "Contains")
          (p ()
            "This patch is built upon the following patches:")
          (ul ()
            ,@(map (fn (name)
                     `(li ()
                        ,(homepage-ref name)
                        " "
                        (i () ,(esc (hack.name 'short)))))
                   it)))))

(def apply-hack (hack)
  (case hack!type
    patch
    `((h2 () "Apply This Hack to Your Arc")
      (p () "By using patch or git, you can incorporate this patch into your version of Arc.")
      (h3 () "With patch")
      (p ()
        "To apply this patch to your copy of arc using the patch command, download "
        (a (href ,(esc (patch-url hack))) ,hack!tag ".patch")
        " into your Arc directory"
        ", and at the Unix command line inside the Arc directory, type:")
      ,(code " patch <" hack!tag ".patch")
      (p ()
        ,(qu "<code>patch</code>") " is a standard utility that comes with Unix.  (If you&rsquo;re running Windows, iirc <code>patch</code> comes with cygwin).")
      (p () "For example,")
      ,(code
        " $ wget http://ycombinator.com/arc/arc2.tar
 [... downloading ...]
 $ tar xf arc2.tar
 $ cd arc2
 $ patch <" hack!tag ".patch
 patching [...]
 $")
      (h3 () "With git")
      (p ()
        "In a git repository that has the same arc2 ancestor commit as mine, git-merge can be used:")
      ,(code "$ git merge " hack!tag)
      (p ()
         "In a repository where arc2 has been checked in as a different commit, running git-merge will produce merge conflicts as it tries to apply both of the arc2 commits.  See the instructions at the end of "
         (a (href "sharing-hacks.html") "Sharing Hacks")
         " for how to resolve the conflict."))))

(def comment-on-hack (hack)
  (aif hack!comment
    `((h2 () "Comment")
      (a (href ,it) "Comment") " in the Arc Forum.")))

(def license (hack)
  (if (is hack!type 'patch)
       `((h2 () "License")
          (p () "The original Arc source is copyrighted by Paul Graham and Robert Morris and licensed under the Perl Foundations's Artistic License 2.0 as described in the “copyright” file in the Arc distribution.")

          (p () "My <i>changes</i> to Arc (this patch that I wrote) are in the "
             (a (href "http://creativecommons.org/licenses/publicdomain/") "public domain")
             ".")

          (p () "The <i>combination</i> of the original Arc and my changes together (what you get after you apply my patch) is also licensed under the Perl Foundations's Artistic License 2.0."))
      (isnt hack!type 'howto)
       `((h2 () "License")
         (p () (a (href "http://creativecommons.org/licenses/publicdomain/") "public domain")))))

(def readfilec (name)
  (apply string
    (w/infile i name (drain (readc i)))))

(def gen (hack)
  `((a (href "/") "Cat’s hacks") ":"
    ,(if (is hack!type 'howto)
          `(h2 () ,(esc hack!short))
          `((h1 () ,(esc (or hack!title hack!name)))
            (p () (i () ,hack!short))))
    ,(if hack!view
       `(pre ()
          ,(esc (readfilec (string "~/git/catdancer.github.com/" hack!tag ".patch")))))
    ,(if (isa hack!long 'fn) (hack!long) hack!long)
    ,(gen-bugs hack)
    ,(gen-contains hack)
    ,(aif (get-hack hack) `((h2 () "Get This Hack") ,it))
    ,(apply-hack hack)
    ,(comment-on-hack hack)
    ,(license hack)
    ,(aif hack!versions
       `((h2 () "Versions")
         ,it))))

(def make-patch (tag)
  (if tag
  (let fn (string "~/git/catdancer.github.com/" tag)
    (system:string
      "cd ~/git/arc && "
      "git-diff arc2 " tag " >" fn ".patch && "
      "cp " fn ".patch " fn ".patch.txt"))))

(def make-patches ()
  (map [make-patch _!tag] (keep [is _!type 'patch] hacks*)))

(def copy-lib (hack)
  (system:string
   "cp ~/git/" (git-repo hack) "/" hack!name ".arc ~/git/catdancer.github.com/")
  (system:string
   "cd ~/git/catdancer.github.com; cp " hack!name ".arc " hack!name ".arc.txt"))

(def copy-libs ()
  (map copy-lib (keep [is _!type 'lib] hacks*)))

(= css "

body {
  font-family: verdana;
  margin-left: 2em;
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

td {
  vertical-align: top;
  padding: 0 1em 0.5em 0;
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
  (mypage (or hack!short hack!name) (gen hack)))

(def write-index-page ()
  (w/outfile f "~/git/catdancer.github.com/index.html"
    (disp doctype* f)
    (disp (nlhtml:index-page) f)
    (disp "\n" f))
  nil)

(def write-doc-page (hack)
  (w/outfile f (string "~/git/catdancer.github.com/" hack!name ".html")
    (disp doctype* f)
    (disp (nlhtml:doc-page hack) f)
    (disp "\n" f)))

(def write-doc-pages ()
  (map write-doc-page (rem [or (is _!type 'mirror) (no _!short)] hacks*)))

(def al ()
  (write-index-page)
  (write-doc-pages)
  (make-patches)
  (copy-libs)
  'ok)
