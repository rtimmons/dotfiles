##
# In-place add a file to the svn:ignore list 
# 
# Works even if file has local modifications
# 
svnignore() {
    local bkup="$1.QCHHW4SN59JW42DDYB1P.$$.bak"
    
    if [ -e "$bkup" ]; then
        echo "backup file [$bkup] already exists.  Cannot ignore."
        return 1
    fi
    
    cp -R "$1" "$bkup" || return 2
    svn rm --force "$1" || return 3
    
    {
        svn propget svn:ignore . 
        echo "$1"
    } | grep '[^\s]' | sort | uniq | svn propset -F /dev/stdin svn:ignore .
    svn up --depth=empty . "$1" || return 4
    
    mv "$bkup" "$1" || return 5
    
    return 0
}