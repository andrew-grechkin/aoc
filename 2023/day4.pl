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

my $data  = path('2023/day4')->slurp;
my @lines = split m/\R/, $data;

my %cards = map {line_to_card($_)} @lines;

say {*STDOUT} sum0 map {$_->{cards}[0]{power}} values %cards;

foreach my ($num) (sort {$a <=> $b} keys %cards) {
    my \@cards = $cards{$num}{cards};
    $cards{$num}{count} = scalar @cards;
    foreach my $card (@cards) {
        for (my $i = 1; $i <= $card->{wonc}; ++$i) {
            my $next_num = $num + $i;
            last if !exists $cards{$next_num};
            push $cards{$next_num}{cards}->@*, $cards{$next_num}{cards}[0];
        }
    }
}

say {*STDOUT} sum0 map {$_->{count}} values %cards;

sub line_to_card ($line) {
    my ($lhs,     $rhs)  = split m/: */,      $line;
    my ($winning, $have) = split m/\s*\|\s*/, $rhs;

    my %winning = map {$_ => 1} split m/\s+/, $winning;
    my @have    = split m/\s+/, $have;
    my ($num)   = $lhs =~ m/(\d+)/x;
    my @won     = grep {exists $winning{$_}} @have;

    my %result = (
        winning => \%winning,
        have    => \@have,
        won     => \@won,
        power   => (@won ? 2**(@won - 1) : 0),
        wonc    => scalar(@won),
    );

    return $num, {cards => [\%result]};
}

__END__
