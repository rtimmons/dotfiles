#!/usr/bin/env perl -w

use strict;
use warnings;

use Carp::Heavy;

my %fs;

for my $ship (<*.txt>) {
    $ship =~ m/^(\d+)\.txt$/;
    my $num = $1;
    $fs{$1} = $ship;
}

my @fs = keys %fs;
my $ship_key = $fs[ rand(@fs) ];

my $fname = $fs{$ship_key};
open SHIP, "< $fname" or die "couldn't open ship $fname";
my $ship = do { local $/; <SHIP> };
close SHIP;

print $ship;
