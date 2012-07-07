
##
# Echo the repository URL for the parent directory of the current 
# checkout.  Useful for merging  other things that require full
# repository paths.
#
# Example:
#
#     $ svn co http://svn.ganon.com/profile/trunk profile
#     $ cd profile
#     $ svnparent 
#     http://svn.ganon.com/profile
# 
###
svnparent() {
    svn info | grep '^URL' \
             | perl -pe  's,^URL:\s*(.*)/.*?$,$1,'
}
