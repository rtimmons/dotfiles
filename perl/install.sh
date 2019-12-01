#!/usr/bin/env bash

mkdir -p "$HOME/perl5/bin"

if [ ! -e "$HOME/perl5/bin/cpanm" ]; then
    curl -fSs "http://cpanmin.us/" > "$HOME/perl5/bin/cpanm"
    chmod +x "$HOME/perl5/bin/cpanm"
fi

"$HOME/perl5/bin/cpanm" File::ExtAttr
