#!/usr/bin/env bash

##
# Dumb thing to help navigate a blot.im blog
# 
#   BLOT_DRAFTS to location of Blot drafts folder
#   BLOT_URL    to url of Blot blog
#

if [ -z "$BLOT_DRAFTS" ]; then
    BLOT_DRAFTS="$HOME/Dropbox/Apps/Blot/Drafts"
fi
if [ -z "$BLOT_URL" ]; then
    BLOT_URL="http://rtimmons.blot.im/"
fi

blot() {
    __blot_usage() {
        local prog="$1"
        echo "Usage:"
        echo "    $prog help | new \"slug\" | copy \"./file\" | open"
    }

    local action="$1"
    if [ -z "$action" ]; then
        __blot_usage "$0"
        return 1
    fi
    
    shift

    case "$action" in
        "help")
            __blot_usage "$0"
            return 1
            ;;
        "copy")
            local src
            src="$1"
            if [ ! -f "$1" ]; then
                __blot_usage "$0"
            fi
            local date
            date="$(date +"%F")"
            local newname
            newname="_$date-$(basename "$src" | tr "[:upper:]" "[:lower:]" | sed 's/ /-/g')"
            local dest
            dest="$BLOT_DRAFTS/../Files/$newname"
            cp "$src" "$dest"
            echo "![alt](/files/$newname)"
            ;;
        "open")
            open -a Finder "$BLOT_DRAFTS"
            open -a Firefox "$BLOT_URL"
            return 0
            ;;
        "new")
            local slug
            slug="$(echo "$@" | tr "[:upper:]" "[:lower:]" | sed 's/ /-/g')"
            if [ -z "$slug" ]; then
                __blot_usage "$0"
                return 1
            fi

            local date
            date="$(date +"%F")"
            local fpath
            fpath="$BLOT_DRAFTS/$date-$slug.md"
            {
                echo "Date: $date  "
                echo "Tags:   "
                echo ""
                echo "# $*"
            } > "$fpath"
            echo "$fpath"
            open "$fpath"
            return 0
            ;;
        *)
            __blot_usage "$0"
            return 1
    esac
}
