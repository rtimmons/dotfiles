#!/usr/bin/env bash

set -eou pipefail

brew install firefoxpwa

# https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data
# https://www.userchrome.org/how-create-userchrome-css.html


mydir=$(dirname "$0")
pushd "${mydir}" >/dev/null
    mydir=$(pwd -P)
popd > /dev/null

chrome_dir="${mydir}/chrome"
if [ ! -d "${chrome_dir}" ]; then
    echo "No chrome dir ${chrome_dir}" >/dev/null
    exit 10
fi

dest="${HOME}/Library/Application Support/Firefox/Profiles"
if [ ! -d "${dest}" ]; then
    echo "No Firefox Profiles in $dest"
    exit 0
fi

for D in "${dest}"/*; do
    echo "Processing ${D}"
    # pushd "${D}" >/dev/null
    if [ -e "${D}/chrome" ]; then
        if [ ! -L "${D}/chrome" ]; then
            echo "${D}/chrome exists and isn't a symlink" >/dev/null
            exit 1
        fi
    else
        ln -s "${chrome_dir}" "${D}/chrome"
    fi
    # popd >/dev/null
done

