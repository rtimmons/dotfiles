
# Add all missing files
svnaddall() {
    svn stat \
        | grep '^\?' \
        | perl -p -e 's/^\?\s+(.*)$/"$1"/g' \
        | xargs svn add
}
