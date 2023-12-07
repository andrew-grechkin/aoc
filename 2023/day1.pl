#!/usr/bin/env perl

use v5.38;
use autodie;
use open ':locale';
use utf8;
use warnings     qw(FATAL utf8);
use experimental qw(builtin class declared_refs defer for_list refaliasing try);

use List::Util qw(sum0);
use Mojo::File qw(path);
use Data::Printer;

sub string_to_number1 ($str) {
    state $first = qr{^ .*? (\d)}x;
    state $last  = qr{^ .*  (\d)}x;
    my @result = (($str =~ $first), ($str =~ $last));
    return join '', @result;
}

sub string_to_number2 ($str) {
    state %nums = (
        one   => 1,
        two   => 2,
        three => 3,
        four  => 4,
        five  => 5,
        six   => 6,
        seven => 7,
        eight => 8,
        nine  => 9,
    );
    state $or    = join '|', keys %nums;
    state $first = qr{^ .*? (\d|$or)}x;
    state $last  = qr{^ .*  (\d|$or)}x;
    my @result = (($str =~ $first), ($str =~ $last));
    @result = map {exists $nums{$_} ? $nums{$_} : $_} @result;
    return join '', @result;
}

my $data     = path('2023/day1')->slurp;
my @lines    = split m/\R/, $data;
my @numbers1 = map {string_to_number1($_)} @lines;
my @numbers2 = map {string_to_number2($_)} @lines;

say {*STDOUT} sum0 @numbers1;
say {*STDOUT} sum0 @numbers2;

__END__
