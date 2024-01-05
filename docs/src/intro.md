# Introducing Devshell: like virtualenv, for every language

**STATUS: unstable**

It should not take more than 10 minutes from the time you clone a repo and can
start contributing.

Unfortunately, an unbounded amount of time is usually spent installing build
dependencies on the system. If you are lucky, it's a pure $LANG project and
all it takes is to install that language and its dedicated package manager. On
bigger projects it's quite common to need more than one language to be
installed. The side-effect of that is that it creates silos withing companies,
and less contributors in the open-source world.

It should be possible to run a single command that loads and makes those
dependencies available to the developer.

And it should keep the scope of these dependencies at the project level, just
like virtualenv.

These are the goals of this project.
