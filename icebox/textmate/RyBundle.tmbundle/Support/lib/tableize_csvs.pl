#!/usr/bin/env perl
use strict;
use warnings;

use IO::File;


sub row {
    my $in = shift;
    return "<tr><td>" . join("</td><td>", csvsplit($in)) . "</td></tr>\n";
}

sub csvsplit {
    my ($in,$separator) = @_;
	my @vals = split(/\s*$separator\s*/, $in);
	foreach(@vals) {
	    chomp;
	    s/^"|"$//g;
    }
    @vals;
}

sub csv_to_table {
    my ($data) = @_;
    
    my @lines = grep { /\S/ } split(/\n/, $data);
    my $header = shift @lines;

    my @cols = csvsplit($header);

    my @out = (
        '<table border="1">'."\n".'<tr>' . 
        join("", map { "<th>$_</th>" } csvsplit($header) ) .
        "</tr>\n"
    );

    for my $line (@lines) {
        push @out, row($line);
    }

    print join '', @out;
    print "</table>";
}

# Return how many times $this occurs within $line
sub occurences_on_line {
    my ($this,$line) = @_;
    my @parts = split($this, $line);
    return @parts ? scalar(@parts)-1 : 0;
}

sub tableize {
    my ($fh, $separator) = @_;
    
    my $on_prev_line = -1;
    while ( <$fh> ) {
        my $on_curr_line = occurences_on_line($separator, $_);
        print($on_curr_line);
    }
}


1;