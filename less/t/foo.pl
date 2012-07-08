#!/usr/bin/env perl

use strict;
use warnings;

print join("\n", map { uc } @ARGV)
