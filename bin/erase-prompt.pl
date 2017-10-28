#!/usr/bin/env perl

use strict;
use warnings;

##
# Dumb script to clean up terminal
# copy/paste output. Assumes `$PS1` of
# `%` and `$RPROMPT` of `cwd` (regex
# looks for something that resembles
# common directories).
##


my $lastEmpty = 0;
while(<>) {
    chomp;
    if (/[^\s]/) {
        $lastEmpty = 0;
    }
    else {
        $lastEmpty++;
    }

    if (/^(% )(.*)( ){3,}+([a-zA-Z0-9\/ \\~]+)$/) {
        # 1: %
        # 2: command
        # 3: a space
        # 4: cwd
        my $line = "\$ $2\n";
        $line =~ s/^\s+|\s+$//g;
        print "$line\n";
    }
    else {
        if ($lastEmpty <= 1) {
            print "$_\n";
        }
    }
}
