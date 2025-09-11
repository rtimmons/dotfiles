#!/usr/bin/perl -w
use strict;
use warnings;

# TODO: finish

sub align {
    my ($input, $at) = @_;
    my @lines = split(/\n/, $input);
    
    my %max_lens = ();
    my %cols = ();
LINES:
    for(my $i=0;$i<scalar(@lines);$i++) {
        my @cols = split $at, $lines[$i];
        $cols{$i} = \@cols;
    COLS:
        for(my $coli=0; $coli<scalar(@cols);$coli++) {
            my $col = $cols[$coli];
            my $len = length($col);
            $max_lens{$coli} = $len
                unless ($max_lens{$coli}||0) > $len;
        }
    }
    
    my @out = ();
    for my $i (sort keys %cols) {
        my @cols = @{$cols{$i}};
        for(my $j=0; $j<scalar(@cols); $j++) {
            
        }
    }
    
    \%max_lens;
}



1;
