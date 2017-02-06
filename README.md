# Git Version Tagging

A script to automatically tag the latest commit on the current branch, if it is 'master', with a new [Semantic Versioning](http://semver.org/) version number.

It relies upon a .version file being present in the root directory of the repository, containing a Semantic Versioning version number in the format: v1.0.x, in which the major and minor version numbers are set, and the patch version number is ignored (this is automatically set).

If the branch's last tagged commit has the same major and minor version numbers as those in the .version file, then the patch version number is incremented and this forms the version number to be used as the tag for the new commit.
If the major or minor numbers are different, or if there are no previous version tags on any commits on the branch, then the patch number is set to 0.
