#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

require "align_pipes.pl";

my $max_lens = align(
q(Foo|Bar|Baz
zBlaz|dffsdf|sdfklhaf),
qr{\|}
);

use Data::Dumper;
print Dumper($max_lens);