#!/usr/bin/env perl -w

use strict;
use warnings;

use Carp::Heavy;

# find a ship
my @ships = <*.txt>;
my $fname = $ships[ rand(@ships) ];

# and print it
open SHIP, '<',$fname or die "couldn't open ship $fname";
print $_ for <SHIP>;
close SHIP;
