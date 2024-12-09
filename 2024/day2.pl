#!/usr/bin/env perl

use v5.40;
use experimental qw(class declared_refs defer refaliasing);

use Getopt::Long qw(:config auto_version bundling no_ignore_case);
use List::Util   qw(all sum0);

use Carp::Assert::More qw(assert_is);
use Log::Any           qw($log);
use Log::Any::Adapter  qw(Stderr), (log_level => 'info');
use Mojo::File         qw(path);
use YAML::XS           qw();

use Data::Printer;

my %options = ('VERBOSE' => 0,);

GetOptions('verbose|v+' => \$options{'VERBOSE'},)
    or die "Unable to process command line options\n";

$log->{'adapter'}{'log_level'} += $options{'VERBOSE'};

my @tasks;
if (-t 0 && !@ARGV) {
    my \@data = YAML::XS::Load(do {local $/ = undef; <DATA>});
    @tasks = map {{input => [map {[split m/\s+/]} split(m/\R/, $_->{input})], test => $_->{test}}} @data;
} else {
    chomp(my @lines = <<>>);
    @lines = map {[split m/\s+/]} @lines;
    @tasks = map {{input => $_}} (\@lines, \@lines);
}

sub adjacent_pairs ($aref) {
    my \@array = $aref;
    my $pairs = @array - 1;

    my @result;
    for (my $i = 0; $i < $pairs; ++$i) {
        push(@result, [$array[$i], $array[$i + 1]]);
    }

    return \@result;
}

sub is_safe ($line_aref) {
    ## no critic [BuiltinFunctions::ProhibitUselessTopic]
    my @diff = map {$_->[0] - $_->[1]} adjacent_pairs($line_aref)->@*;
    return (all {1 <= abs($_) <= 3} @diff) && ((all {$_ > 0} @diff) || (all {$_ < 0} @diff));
}

my @solutions = (
    sub($input_aref) {
        my \@input = $input_aref;

        my $safe = 0;

        foreach my \@line(@input) {
            my $is_safe = is_safe(\@line);
            $safe++ if $is_safe;
        }

        return $safe;
    },
    sub($input_aref) {
        my \@input = $input_aref;

        my $safe = 0;
        foreach my \@line(@input) {
            my $is_safe = is_safe(\@line);
            $safe++ if $is_safe;
            next    if $is_safe;

            for (my $i = 0; $i < @line; ++$i) {
                my @copy = @line;
                splice(@copy, $i, 1);
                $is_safe = is_safe(\@copy);
                $safe++ if $is_safe;
                last    if $is_safe;
            }
        }

        return $safe;
    },
);

foreach my ($i, $task) (builtin::indexed(@tasks)) {
    my $result = $solutions[$i]->($task->{input});
    assert_is($result, $task->{test}, 'correct result with test data') if $task->{test};
    say {*STDOUT} sprintf 'task %d result: %d', $i + 1, $result;
}

__DATA__
---
- input: |-
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
  test: 2
- input: |-
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
  test: 4
