#!/usr/bin/perl

# battery.pl
# 
# Perl script that displays to the terminal the charge on your Mac Intel battery (and takes
# a guess as to how much time is left on the charge).
# 
# Version 1.0 (010308) - Hey, it works!
#         1.1 (010408) - Added debugging code; added IsCharging test; changed symbols for TimeLeft.
#         1.2 (011208) - "Fixed" some weirdness with the battery being at less than 100% capacity,
#                        but still reading "FullyCharged" or reading "FullyCharged" while also 
#                        reading "IsCharging." Wacky.
# 
# Author: P. Ham - pham@sdf.lonestar.org
# 
# Cryptic Notes: 65535 may just be a kludge number to mean "infinity."
# See http://en.wikipedia.org/wiki/65535_(number).

use strict;
use Data::Dumper;
my $IOREG = "/usr/sbin/ioreg";

my $output = `$IOREG -nAppleSmartBattery`;
my @output = split("\n", $output);
my $batteryHash;

foreach (@output) {
    if (/\"(MaxCapacity)\"\s+=\s+(\d+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(DesignCapacity)\"\s+=\s+(\d+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(CurrentCapacity)\"\s+=\s+(\d+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(AvgTimeToEmpty)\"\s+=\s+(\d+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(AvgTimeToFill)\"\s+=\s+(\d+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(TimeRemaining)\"\s+=\s+(\d+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(IsCharging)\"\s+=\s+(\w+)/) {
	    $batteryHash->{$1} = $2;
	} elsif (/\"(FullyCharged)\"\s+=\s+(\w+)/) {
	    $batteryHash->{$1} = $2;
	} 
}

my $DEBUG = 0;
print Dumper $batteryHash if $DEBUG;

my $percentCapacity = ( $batteryHash->{"CurrentCapacity"} / $batteryHash->{"MaxCapacity"} ) * 100;
$percentCapacity = int($percentCapacity + .5 * ($percentCapacity <=> 0));

my $timeLeft;
if ($batteryHash->{"IsCharging"} eq "Yes" && $batteryHash->{"FullyCharged"} eq "No") {
    # battery is charging so can't calculate time left (yet)
    $timeLeft = "( + )";
    # $timeLeft = "(~/~)";
} elsif ($batteryHash->{"FullyCharged"} eq "Yes") {
    $timeLeft = "( f )";
} elsif ($percentCapacity != 100) {
    # OK, calculate time left
    $timeLeft = $batteryHash->{"TimeRemaining"} / 60;
    my ($hours, $minutes) = split(/\./, $timeLeft);
    $minutes = 60 * ( "." . $minutes );
    $minutes = int($minutes + .005 * ($minutes <=> 0));
    $minutes = sprintf ("%02d", $minutes);
    $timeLeft = "($hours:$minutes)";
} else {
    # not charging and 100% capacity
    # $timeLeft = "( - )";
    $timeLeft = "( f )";
}

print "$percentCapacity% $timeLeft\n";

exit;


