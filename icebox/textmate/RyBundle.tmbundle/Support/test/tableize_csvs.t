#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::More qw/no_plan/;


require "tableize_csvs.pl";

is(occurences_on_line("_", "foo_bar"), 1);
is(occurences_on_line("_", "foobar",), 0);
is(occurences_on_line("_", "foo_bat_bar_baz",), 3);



use IO::Handle;
my $io = new IO::Handle;
my $fp = *DATA{IO};
tableize($fp, qr{\|});
print "\n";



__DATA__
a
    b|
|c|

Table:

    "FOO"|"BAR"|"BAZ"
    "NOMNOM"|"NOMNOM"|"NOMNOM"

