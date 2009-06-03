(edef code content
  `(blockquote () (pre () ,(esc (apply string content)))))

(= darc (qu "<code>.arc</code>"))

(def indent xs
  `(div (style "margin-left: 2em") ,@xs))

(= hacks* (list

  (obj
   name "using-git-commits-for-hacks"
   type 'howto
   short "Using Git Commits for Hacks"
   comment "http://arclanguage.org/item?id=9481"

   long
   `((p () "Here I show how to use Git as a mechanism for programmers to load libraries and patches, as an alternative to the usual approach of downloading, installing, and loading libraries into a program.")

     (p () "This is using Git in an unusual way, as Git is normally used as a version control system.  You can still use Git as a version control system to develop a library, if you want to, and then publish your library using this system; I describe the details below.")

     (p () "With this mechanism patches gain the ease of use and the flexibility of libraries: an end-programmer can pick and choose which patches they want, and patches can be loaded in the same way and just as easily as loading libraries.")

     (p () "Libraries gain the lightweight characteristics of patches: if a library is missing some feature or two libraries conflict, it’s easy to share a patch which resolves the issue.")

     (p () "As patches and libraries become more alike and can be shared and used in the same way, I use “hack” as a generic term to mean something which is either a patch or a library, or a bit of both.")

     (p () "Because I’ve just started working on this idea, the examples show using raw Git commands to pick which hacks you want.  Presumably, if this works out, we’ll eventually write some higher level commands that will be easier to use.")

     (h3 () "Using Git for hacks vs. using Git as a version control system")

     (p () "When using Git for hacks:")

     (ul ()
       (li () "A Git checkout is a program or library and the libraries and patches that it depends on.")
       (li () "A Git repository can store the code and for multiple libraries, patches, and programs.")
       (li () "Each Git commit represents a particular library or patch.")
       (li () "Dependencies (library A uses library B which needs library C) are represented by ancestors of commits, and are automatically pulled in using Git’s merge mechanism."))

     (p () "When Git is used in the usual way as a version control system:")

     (ul ()
       (li () "A Git checkout is a particular version of one program or library.")
       (li () "A Git repository stores the code and development history for that program or library.")
       (li () "Each Git commit is a snapshot of the development history.")
       (li () "Loading libraries and dependencies are managed in some way outside of Git: for example, one library may “import”, “use”, or “require” another."))

     (p () "You can use Git for both if you want, even in the same Git respository: you can develop a library using Git in the usual way as a version control system keeping track of your development process and then use Git to share your library.")

     (p () "However you can’t take a version control style commit with development history ancestors and share it directly.  Instead you need to create a new commit which has only prerequisite hacks as ancestors.  The process is somewhat similar to “"
       (a (href "http://www.kernel.org/pub/software/scm/git/docs/user-manual.html#patch-series") "creating the perfect patch series")
       "” described in the Git manual.")

     (h3 () "Using Git to pull in some hacks")

     (p () "As an example of using Git to pull in some libraries and their prerequisites, suppose someone wanted to write a program that used my table-reader-writer hack and my mz hack.  They could start off with:")

     ,(code "
 $ mkdir myprog
 $ cd myprog
 $ git init
 $ git pull git://github.com/CatDancer/arc.git tag arc2.table-reader-writer0
 $ git pull git://github.com/CatDancer/arc.git tag arc2.mz0
")

     (p () (i () "[tag names are going to be changed to be globally unique]"))

     (p () "Dependencies are automatically pulled in by this process. For example, table-reader-writer builds upon arc2, so arc2 is pulled in.  table-reader-writer also needs the list-writer and scheme-values hacks, so those are pulled in as well.")

     (p () "Sometimes a hack will conflict with another hacks.  To resolve the conflict, a programmer can share a commit which resolves the conflict.")

     (p () "In Git tag names are not usually globally unique; a typical tag name in normal Git usage will be something like “v4.01”.  If we’re going to be using Git to combine hacks written by different people then we’ll need unique tag names.  I propose using our Arc forum username as a prefix, which will be good enough for now.")

     (h3 () "Sharing a Library")

     (p () "Suppose you have some libraries that you’d like to share using this approach.  You’d do each library separately, but you can do all your work within one Git repository if you wish.  Start off with a clean copy of arc3 (or whatever is your base):")

     (p () (i () "[these tag names don’t exist yet]"))

     ,(code "
 $ git checkout pg.arc3
")

     (p () "As “pg.arc3” is a tag, Git will warn you that you are no longer on a branch.  This is OK, you don’t need a branch for the following, though you can work within a branch if you want to.  Then pull in any hacks that your library depends on:")

     ,(code "
 $ git merge catdancer.arc3.table-reader-writer0
 $ git merge someone-else.some-other-library
")

     (p () "Make the changes which implement your library in your working directory.  You can do this by hand, or, if you’ve developed your library using Git in the normal way with branches and commits keeping track of your development history, you can use “git-apply” or “git-cherry-pick” with the “-no-commit” option to pull the changes into your working directory without committing them.")

     (p () "Don’t use any Git command which commits for you: that will automatically add your development history as ancestors to the commit, and we only want prerequisite hacks as commit ancestors.")

     (p () "Now commit your changes:")

     ,(code "
 $ git commit -m 'my library v1'
")

     (p () "You can see which ancestor commits were included with:")

     ,(code "
 $ git log --decorate --topo-order
")

     (p () "The “decorate” option shows you the tag name associated with each commit, and “--topo-order” shows you the commits in dependency order instead of in order by the date in which they were created.  What you want to see is that only your library and it’s prerequisites appear: that you don’t have other unrelated hacks or development history commits included.")

     (p () "If you make a mistake, just clean out your changes with “git-reset --hard” and start over with the checkout command.")

     (p () "Looks good?  Now tag it:")

     ,(code "
 $ git tag yourname.library-name-v1
")

     (p () "If you’re already set up with a remote public repository such as at Github, you can push your changes to share them:")

     ,(code "
 $ git push --tags
")

     (p () "If you don’t have a public Git repository yet, you can go over to github.com, sign up for a free account, and create a new repository.  Github will give you some instructions on what to do next, use the ones under “Existing Git Repo”:")

     ,(code "
 cd existing_git_repo
 git remote add origin git@github.com:...
 git push origin master
")

     (p () "and then do the “git push --tags”.")

     (p () "If you accidentally share a tag to some bad code or a commit which has some unneeded ancestor commits, delete the tag locally:")

     ,(code "
 $ git tag -d yourname.library-name-v1
")
     (p () "and then explicitly push that now non-existent tag in order to get it deleted on the remote public repository:")

     ,(code "
 $ git push origin :refs/tags/yourname.library-name-v1
")

     (p () "Never reuse a tag name for a different commit after you’ve shared it.  Instead, make up a new tag name, such as “yourname.library-name-v2”.  If people ask you what happened to v1, just say it was a bad commit you shared accidentally.")

     (p () "OK!  You’ve shared your commit, so now other people can get your library:")

     ,(code "
 $ git pull git://github.com/yourname/yourrepo.git yourname.library-name-v2
")


  (h3 () "Resolving Conflicts")

  (p () "Sometimes two hacks will conflict, either in the source code (for example, two patches change the same section of code) or semantically (for example, two libraries try to define a function with the same name).")

  (p () "Two resolve the conflict, share a commit which has the two conflicting hacks as ancestor commits:")

  ,(code "
 $ git merge hack-a
 $ git merge hack-b
 [fix fix fix]
 $ git commit -m 'merge hack-a and hack-b'
 $ git tag myname.hack-a.hack-b
 $ git push --tags
")

  (p () "Then when someone wants to use hack-a and hack-b, they can say, “hey! you've already fixed this!” and grab your myname.hack-a.hack-b.")

  (p () "You can do the same thing if you need to advertise that two hacks <i>don’t</i> conflict with each other.  For example, I published a “toerr” hack which built upon arc2.  As it happens, it merges fine against arc3:")

  ,(code "
 $ git checkout pg.arc3
 $ git merge catdancer.arc2.toerr0
")

  (p () "But if people were worried if it worked with arc3, I could share that commit:")

  ,(code "
 $ git tag catdancer.arc3.toerr0
")

  (p () "While in this case there are no code differences between the arc2 versions of toerr and the arc3 version, my sharing this commit with pg.arc3 and catdancer.arc2.toerr0 as ancestors is a way for me to say that they work together.")

  (h3 () "Including ancestor commits without their code")

  (p () "Sometimes we’ll want to include a commit as an ancestor of our commit, even though we're not using any code from it.")

  (p () "For example, suppose Alice shares a library L1, and Bob creates a bug fix for that library F1.  Then Cindy writes a library L2 which uses L1 and needs the bug fix F1.  The commit for L2 will have F1 as a parent commit, so that it gets pulled in automatically if someones uses L2.")

  (p () "Imagine that F1 is actually a pretty ugly fix, and we’re writing a fix F2 which is a better replacement.  F2 fixes the problem that F1 fixed, but in a different and better way, and without using any of F1’s code.")

  (p () "We’d like F2 to have F1 as a parent commit, because then someone can merge F2 and L2 and everything will work.  If F2 didn't have F1 as a parent commit, then when someone merged L2, Git would attempt to also merge in the F1 code.")

  (p () "If while preparing the F2 commit we were to type “<code>git merge --no-commit F1</code>”, this would do two things: it would add the F1 commit to our <code>.git/MERGE_HEAD</code> so that it will be included as a parent commit later when we run “<code>git commit</code>”, and it would pull in the F1 changes into our working directory. We’d then need to tediously remove the F1 changes.")

  (p () "We can actually just add the F1 commit to our <code>MERGE_HEAD</code> ourselves, without using <code>git merge</code> at all:")

  ,(code "
 $ git rev-parse F1 >>.git/MERGE_HEAD
")

  (p () "Now F1 will be included as one of the parent commits when we “<code>git commit</code>”, without having any of F1’s code in our working directory.")

  (h3 () "Unresolved Issues")

  (p () "Loading libraries by adding them to libs.arc will almost always produce a unnecessary conflict in libs.arc when two unrelated libraries are merged.  That can be resolved by having Arc load all the .arc files in a lib directory, but we would still need some mechanism to have libraries loaded in the right order when one library uses macros defined in another library.")
  
     ))

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
        "By itself this patch is supposed to produce the same output as <code>arc2</code> does.  (If it doesn’t, that would be a bug).")))

  bugs
  '("Attempting to write a list containing a cycle will enter an infinite loop and crash MzScheme by consuming all available memory.")
  )

 (obj
  name "load-rename"
  title "load-w/rename"
  type 'patch
  git-repo "arc"
  tag "arc2.load-rename0"
  comment "http://arclanguage.org/item?id=9202"

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

  (obj
   name "testify-table"
   type 'patch
   git-repo "arc"
   tag "arc2.testify-table0"
   comment "http://arclanguage.org/item?id=9214"

   short "Treat tables like functions in Arc's list sequence functions"

   show-patch "
 (def testify (x)
-  (if (isa x 'fn) x [is _ x]))
+  (if (in (type x) 'fn 'table) x [is _ x]))
"

   long
   `((h3 () "Why not to use this patch")
     (p () "When structs or objects are implemented as tables, code such as “take these objects out of my list of objects” will stop working with this patch.  See "
        (a (href "http://news.ycombinator.com/item?id=616071") "Duplicates appearing in HN top?") " for an example.")
     (h3 () "Description")
     (p ()
       "Arc comes with a number of functions that apply a function to successive elements of a sequence.  From the "
       (a (href "http://ycombinator.com/arc/tut.txt") "Arc tutorial")
       ":")
     ,(code "
  arc> (keep odd '(1 2 3 4 5 6 7))
  (1 3 5 7)
  arc> (rem odd '(1 2 3 4 5 6))
  (2 4 6)
  arc> (all odd '(1 3 5 7))
  t
  arc> (some even '(1 3 5 7))
  nil
  arc> (pos even '(1 2 3 4 5))
  1
")
     (p () "If the first argument isn’t a function, it is treated like a function that tests for equality with that (again, from the Arc tutorial):")

     ,(code "
  arc> (rem 'a '(a b a c u s))
  (b c u s)
")

     (p () "Since a table isn’t a function, if you pass it as the first argument, it gets treated as a value to test for equality with.")

     (p () "This patch changes Arc so that tables are instead treated like functions are:")

     ,(code "
  arc> (rem (obj a t c t) '(a b a c u s))
  (b u s)
")

     (p () "In arc2 this evaluates to <code>'(a b a c u s)</code>, since none of the elements of the list is the table.  Of course, this means you can no longer check for a table in a list of tables without resorting to writing your own function to check for equality:")

     ,(code "
  arc> (with (t1 (obj a 1) t2 (obj a 2) t3 (obj a 3))
         (rem t2 (list t1 t2 t3)))
  (#hash((a . 1)) #hash((a . 3)))                 <--- arc2
  (#hash((a . 1)) #hash((a . 2)) #hash((a . 3)))  <--- with this patch
")

     (p () "I use this patch in my code since I often want to do the former and have yet to need to do the latter, so this patch makes my code more concise.")
     ))

  (obj
   name "testify-iso"
   type 'patch
   git-repo "arc"
   tag "arc2.testify-iso0"
   nolicense t
   comment "http://arclanguage.org/item?id=9227"

   short "Allow lists to be used as the first argument to Arc's list sequence functions."

   show-patch "
 (def testify (x)
-  (if (isa x 'fn) x [is _ x]))
+  (if (isa x 'fn) x [iso _ x]))
"

   long
   `((table (class code)
       (tr ()
          (th ())
          (th ())
          (th () "arc2")
          (th ())
          (th () "patch"))
       (tr ()
          (td ()
            "(rem '(c d) '((a b) (c d) (e f)))")
          (td (class arrow)
            "&rArr;")
          (td ()
             "((a b) (c d) (e f))")
          (td (class spacer) "&nbsp;")
          (td ()
             "((a b) (e f))"))
       (tr ()
          (td ()
            "(pos '(4 5) '(1 2 3 (4 5) 6))")
          (td (class arrow))
          (td ()
             "nil")
          (td (class spacer))
          (td ()
             "3")))
     (br ())
     (br ())))

  (obj
   name "obj-no-atomic"
   type 'patch
   git-repo "arc"
   tag "arc2.obj-no-atomic0"

   short "Avoid unnecessary use of atomic by obj"

   show-patch "
  (mac obj args
    (w/uniq g
      `(let ,g (table)
 -       ,@(map (fn ((k v)) `(= (,g ',k) ,v))
 +       ,@(map (fn ((k v)) `(sref ,g ,v ',k))
                (pair args))
         ,g)))
"

   long
   `((p (style "padding: 1em; border: 1px solid green")
       (b () "Update:")
       " see "
       (a (href "http://arclanguage.org/item?id=9288") "http://arclanguage.org/item?id=9288")
       " for an approach which fixes the bug of <code>obj</code> evaluating its value arguments too late, instead of working around the bug by avoiding <code>=</code>.")

     (p () "I use <code>obj</code> a lot in my code, using tables as objects/structs, and as I was condensing my code I began to get forms like:")

     ,(code "
 (obj a (if foo (throw nil) ...)

 (obj a (readfile \"foo\"))
")

     (p () "<code>obj</code> expands into a call to = to store the individual values in the new table, and arc2 protects expansions of = with atomic.  The first form above generates an error since the throw can’t cross the continuation boundary created by atomic, and the second is dangerous since any delay inside of a call to atomic will cause all other uses of atomic to hang until it is done.")

     (p () "However, in the case of <code>obj</code> there’s no need to protect the setting of the table values since the newly created table will not be visible to other threads at least until <code>obj</code> returns.  Thus the creation of the table can be done outside of the protection of atomic.")

     (p () "With this patch the first form now works:")

     ,(code "
arc> (catch (obj a (throw nil)))
nil
")

     (p () "And the second has no danger of hanging other threads.")
     ))

  (obj
   name "nil-impl-by-null"
   type 'patch
   git-repo "arc"
   tag "arc2.nil-impl-by-null0"
   comment "http://arclanguage.org/item?id=9300"

   contains '("list-writer")

   short "Speculative patch implementing Arc's nil with MzScheme's null"

   long
   `((p ()
        "This rough patch to arc2 tries out implementing Arc’s <code>nil</code> internally with MzScheme’s <code>null</code> <code>'()</code>, instead of using MzScheme's <code>nil</code> symbol.")

     (p ()
        "From inside of Arc nothing has changed: lists are still terminated by <code>nil</code>, <code>nil</code> is still a symbol, <code>nil</code> still reads and prints as <code>nil</code>, and so on.  Only the internal representation of <code>nil</code> has changed.")

     (p ()
        "This simplifies the Arc compiler since it doesn’t have to convert back and forth between <code>nil</code> and <code>'()</code> all the time.")
     )

   bugs
   '("I took a weed-wacker to ac.scm and blindly removed all the ac-denil’s and ac-niltree’s.  I did no analysis of the code I was changing, so I expect I probably messed some things up. The extent of my testing was to run the patched Arc on one of my web pages and see that it didn’t crash.  But hey, it ran 7% faster."
     "I see one mistake already: I took out the check for setting nil when I should have changed it to check for setting '()."

     "This patch depends on the list-writer patch to print <code>nil</code> as <code>nil</code>, and so shares that patch’s bug that writing lists containing cycles will go into an infinite loop, consume all your memory, and crash MzScheme.")
   )

  (obj
   name "srv-mime"
   type 'patch
   git-repo "arc"
   tag "arc2.srv-mime0"
   comment "http://arclanguage.org/item?id=9311"

   short "Fix mime types in srv.arc"

   long
   `((p () "In arc2 this hack removes some code duplication in srv.arc (resulting in a codetree decrease of 17), and fixes the Content-Type MIME types produced for static files with the .css and .txt extensions.")
     (p () "In arc3 the code duplication has already been removed, and so this hack simply fixes the Content-Type MIME types produced for static files with the .css and .txt extensions.")
     ))

  (obj
   name "port-line-counting"
   type 'patch
   git-repo "arc"
   tag "arc2.port-line-counting0"
   comment "http://arclanguage.org/item?id=9312"

   short "Show the line number in some error messages"

   show-patch "
 +(port-count-lines-enabled #t)
"
   long
   `((h3 () "Why not to use this patch")
     (p ()
        "When I try to run my application with this patch applied to Arc in MzScheme version 352, MzScheme crashes with “Process scheme segmentation fault”.  I don’t know if this problem may have been fixed in some later version of MzScheme.")
     (h3 () "Description")
     (p () "This patch turns on MzScheme’s port line counting feature.  This means that some Arc errors will now display the line number of the error.")

     "buggy.arc:"
     ,(code "
 1: (def a (x)
 2:   (+ 3 x))
 3:
 4: (def b (y) <-- parenthesis at beginning of line not closed
 5:   (* y 4)
 6:
 7: (def c (z)
 8:   (/ (b z) 4))
")

     (p () "Before:")

     ,(code "
 arc> (load \"buggy.arc\")
 Error: \"buggy.arc::23: read: expected a ')'\"
")

     (p () "After:")

     ,(code "
  arc> (load \"buggy.arc\")
  Error: \"buggy.arc:4:0: read: expected a ')'\"
")
     ))

  (obj
   name "toerr"
   type 'patch
   git-repo "arc"
   tag "arc2.toerr0"

   short "Send output going to stdout to stderr instead"

   show-patch "
 +(mac toerr body
 +  `(w/stdout (stderr) ,@body))

  (def ero args
 -  (w/stdout (stderr)
 +  (toerr
      (each a args
  ...
"

   long
   `((p () "This is a little macro that I find useful.  It takes output that normally would go to stdout and sends it to stderr instead.  (I call it <code>toerr</code> by analogy with <code>tostring</code>, which takes output going to stdout and puts it in a string).")

     (p () "When used inside of a defop, it causes output to print on the Arc REPL instead of being sent to the user’s browser.")

     ,(code "
 (defop foo req
   (toerr:ppr ...)
")))

;;  (obj
;;   name "arc-libaries"
;;   type 'howto
;;   short "Arc Libraries"

;;   long
;;   `((p () "This howto proposes an approach for writing Arc libraries, and examines the usefulness of git for supporting this approach.")

;;     (h3 () "The evolution of libraries")

;;     (p ()
;;        "In the beginning there was Arc:")

;;     ,(code "
;;  arc
;; ")

;;     (p ()
;;        "Then programs written in Arc:")

;;     ,(code "
;;       program-a
;;       program-b
;;  arc  program-c
;;       program-d
;;       program-e
;; ")

;;     (p ()
;;        "And some of the code in the programs could be usefully extracted into libaries, making the total amount of code needed less:")

;;     ,(code "
;;                  program-a
;;       library-a  program-b
;;  arc  library-b  program-c
;;       library-c  program-d
;;                  program-e
;; ")
;;     (p () "For these particular set of five programs, there is some way of writing the libraries A-C and the programs A-E so that the total amount of code in the libraries and programs is at a minimum.")

;;     (p () "If the libraries and programs are written in this way, then when we add another program F we will likely find that F needs some features that the libraries don’t yet provide (since they only implement the minimum needed for the programs A-E), and so some libraries may need to be updated:")

;;     ,(code "
;;                   program-a
;;       library-a'  program-b
;;  arc  library-b   program-c
;;       library-c'  program-d
;;                   program-e
;;                   program-f
;; ")

;;     ))

  (obj
   name "arc3-hacks-preview"
   type 'howto
   comment "http://arclanguage.org/item?id=9496"

   short "A preview of some arc3 hacks"

   long
   `((table (class foo)
       (tr ()
         (th () "Hack")
         (th () "Tag"))
       ,@(map (fn ((name title tag))
                `(tr ()
                   (td (valign bottom)
                     ,@(if name
                            `((a (href ,(string name ".html")) ,name)
                              (br ())))
                     ,title)
                   (td (valign bottom)
                     (code () ,tag))))
              '(("exit-on-eof" "Exit Arc on ^D" "catdancer.arc3rc3.exit-on-eof0")
                ("table-reader-writer" "Reader / writer for Arc tables" "catdancer.arc3rc3.table-reader-writer0")
                (nil "Merge of exit-on-eof with scheme-values, used by table-reader-writer" "catdancer.arc3rc3.exit-on-eof0.scheme-values0")
                ("testify-iso" "Allow lists to be used as the first argument to Arc's list sequence functions" "catdancer.arc3rc3.testify-iso0")
                ("testify-table" "Treat tables like functions in Arc's list sequence functions" "catdancer.arc3rc3.testify-table0")
                (nil "Merge of testify-iso and testify-table" "catdancer.arc3rc3.testify-table0.testify-iso0")
                ("toerr" "Send output going to stdout to stderr instead" "catdancer.arc3rc3.toerr0")
                ("srv-mime" "Fix the mime types returned for static files with the .css and .txt extensions." "catdancer.arc3rc3.srv-mime0")
                (nil "Add the .js static filetype" "catdancer.arc3rc3.srv-js-filetype0")
                (nil "Extract a function named *dispatch* from *respond* in srv.arc, creating a useful hook to use with *extend* set up your own rules for responding to requests." "catdancer.arc3rc3.srv-dispatch1")
                )))
     (p (style "margin-top: 2em") "Each hack may be applied to your copy of Arc independently.  For example, if you happened to want the table-reader-writer and the toerr hacks, you could type:")

     ,(code "
 $ mkdir arc
 $ cd arc
 $ git init
 $ git pull git://github.com/CatDancer/arc.git tag catdancer.arc3rc3.table-reader-writer0
 $ git pull git://github.com/CatDancer/arc.git tag catdancer.arc3rc3.toerr0
")

     (p () "Your arc directory will now contain a copy of Arc with these two patches applied, along with a couple of other patches (scheme-values and list-writer) which were needed by the patches you asked for.")

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

(def pull-command (hack)
  (string
   "$ git pull git://github.com/CatDancer/arc.git tag "
   hack!tag))

(def apply-hack (hack)
  (case hack!type
    patch
    `((h2 () "Apply This Hack to Your Arc")
      (p () "By using git or patch, you can incorporate this patch into your version of Arc.")

      (h3 () "With git")
      ,(code " " (pull-command hack))
      (p () "For example,")
      ,(code
        " $ mkdir arc
 $ cd arc
 $ git init
 " (pull-command hack))

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
 $"))))

(def comment-on-hack (hack)
  (aif hack!comment
    `((h2 () "Comment")
      (a (href ,it) "Comment") " in the Arc Forum.")))

(def license (hack)
  (if hack!nolicense
       nil
      (is hack!type 'patch)
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
            ,(aif hack!show-patch
                    (code it))
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
