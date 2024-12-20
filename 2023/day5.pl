#!/usr/bin/env perl

use v5.38;
use autodie;
use open ':locale';
use utf8;
use warnings     qw(FATAL utf8);
use experimental qw(builtin class declared_refs defer for_list refaliasing try);

use List::Util qw(first min pairs);

use Future::AsyncAwait;
use Mojo::File    qw(path);
use Mojo::Promise qw();

use Data::Printer;

chomp(my $data = path('2023/day5')->slurp);
my @paragraphs = split m/\R{2,}/, $data;

my $seeds  = (split m/: ?/, (shift @paragraphs))[1];
my @seeds1 = map {[$_, 1]} split m/\s+/, $seeds;
my @seeds2 = pairs split m/\s+/, $seeds;

my @maps = map {[map {[map {int} split m/\s+/]} split m/\R/, s{.*? :\s*\R}{}xr]} @paragraphs;

say {*STDOUT} 'Solution 1';
my $answer1 = await run_parallel(\@seeds1);
say {*STDOUT} "Answer 1: $answer1";

say {*STDOUT} 'Solution 2';
my $answer2 = await run_parallel(\@seeds2);
say {*STDOUT} "Answer 2: $answer2";

## no critic [ValuesAndExpressions::RequireInterpolationOfMetachars]

async sub run_parallel ($seeds_pairs_aref) {
    my @results = await Mojo::Promise->map(
        {concurrency => 9},
        sub ($pair) {
            Mojo::IOLoop::Subprocess->new->run_p(sub {
                my $min = solve($pair->@*);
                return $min;
            })->then(sub ($value) {
                say "Subprocess finished for @$pair: $value";
                return $value;
            })->catch(sub ($err) {
                chomp($err);
                say "Subprocess error: $err";
            });
        },
        $seeds_pairs_aref->@*,
    );

    return min map {$_->[0]} @results;
}

sub solve ($start, $length) {
    my $min;

    for (my $i = $start; $i < $start + $length; ++$i) {
        my $point = $i;
        foreach my $map (@maps) {
            my $good_map = first {defined map_match($point, $_)} $map->@*;
            $point = $good_map ? map_match($point, $good_map) : $point;
        }

        $min = $point if !defined $min || $point < $min;
    }

    return $min;
}

sub map_match ($num, $map) {
    my ($dst, $src, $len) = ($map->@*);
    my $result;
    if ($src <= $num < $src + $len) {
        $result = $dst + ($num - $src);
    }
    return $result;
}

__END__
