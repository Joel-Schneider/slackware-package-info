# slackware-package-info
Slackware package information, taken from installed packages, and sbopkg

A very easy (but messy) script to look for information about a slackware package, whether installed or not.

Colour coded, depending on if it's already installed or not.

Gives dependency information for "slackbuilds.org" packages.

# Requires
sbopkg, with queuefiles for slackbuilds.org support.

# Usage:

[Make sure you have run ``sqg -a`` as root first, if you want slackbuilds.org dependency information.]

```
inf.sh packagename
```
