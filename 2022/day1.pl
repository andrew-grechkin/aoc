#!/usr/bin/env perl

use v5.38;
use autodie;
use open ':locale';
use utf8;
use warnings     qw(FATAL utf8);
use experimental qw(builtin class declared_refs defer for_list refaliasing try);

use List::Util qw(max sum0);
use Mojo::File qw(path);

my $data       = path('2022/day1')->slurp;
my @paragraphs = split m/\R{2,}/, $data;
my @elves      = map {[split m/\R/]} @paragraphs;
my @calories   = reverse sort {$a <=> $b} map {sum0 $_->@*} @elves;
my @slice      = @calories[0 .. 2];

say {*STDOUT} $slice[0];
say {*STDOUT} (sum0 @slice);

__END__
