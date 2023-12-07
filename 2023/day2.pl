#!/usr/bin/env perl

use v5.38;
use autodie;
use open ':locale';
use utf8;
use warnings     qw(FATAL utf8);
use experimental qw(builtin class declared_refs defer for_list refaliasing try);

use List::Util qw(sum0 max);
use Mojo::File qw(path);
use Data::Printer;

sub str_to_pick ($picks_aref) {
    return {
        map {
            my ($amount, $color) = split m/ /;
            ($color, $amount);
        } $picks_aref->@*
    };
}

sub str_to_max ($str) {
    my @round_strs      = split m/; ?/, $str;
    my @round_pick_strs = map {[split m/, ?/]} @round_strs;
    my @round_picks     = map {str_to_pick($_)} @round_pick_strs;

    return {
        red   => int(max map {$_->{red}   // 0} @round_picks),
        green => int(max map {$_->{green} // 0} @round_picks),
        blue  => int(max map {$_->{blue}  // 0} @round_picks),
    };
}

sub line_to_game ($str) {
    my ($lhs, $rhs) = split m/: ?/, $str;

    my ($num) = $lhs =~ m/(\d+)/x;
    my \%max = str_to_max($rhs);

    my %result = (
        num   => $num,
        max   => \%max,
        power => $max{red} * $max{green} * $max{blue},
    );

    return \%result;
}

my $data  = path('2023/day2')->slurp;
my @lines = split m/\R/, $data;

my @games = map {line_to_game($_)} @lines;

my %input = (
    red   => 12,
    green => 13,
    blue  => 14,
);

my @filtered_games
    = grep {$_->{max}{red} <= $input{red} && $_->{max}{green} <= $input{green} && $_->{max}{blue} <= $input{blue}}
    @games;

say {*STDOUT} sum0 map {$_->{num}} @filtered_games;
say {*STDOUT} sum0 map {$_->{power}} @games;

__END__
