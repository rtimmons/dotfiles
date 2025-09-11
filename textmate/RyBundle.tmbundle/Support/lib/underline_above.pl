#!/usr/bin/perl -w

use strict;


# lineno:   the line number of stdinput that corresponds
#           to the line *below* the line of desired underline
#           length.
# uc_char:  the character(s) to repeat
sub underline_above {
    my ($lineno, $uc_char) = @_;
    my $lineabove = undef;
    while(<>) {
      if ( $. == ($lineno - 1) ) {
          chomp($lineabove = $_);
          last;
      }
    }

    my ($spaces,$text) = 
        $lineabove =~ /^(\s*)(.*)\s*$/;

    my $howmany = length($text);

    # print $spaces;
    return $uc_char x ($howmany/length($uc_char)) unless $howmany <= 0;
}


1;
