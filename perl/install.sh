#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/perl5/bin"

if [ ! -e "$HOME/perl5/bin/cpanm" ]; then
    curl -fSs "http://cpanmin.us/" > "$HOME/perl5/bin/cpanm"
    chmod +x "$HOME/perl5/bin/cpanm"
fi

if ! perl -MFile::ExtAttr -e1 >/dev/null 2>&1; then
    "$HOME/perl5/bin/cpanm" --quiet File::ExtAttr
fi
