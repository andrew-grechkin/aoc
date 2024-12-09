#!/usr/bin/env perl

use v5.40;
use experimental qw(class declared_refs defer refaliasing);

use Getopt::Long qw(:config auto_version bundling no_ignore_case);
use List::Util   qw(sum0);

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

my @solutions = (
    sub($input_aref) {
        my \@input = $input_aref;

        my (@left, @right, @dist);
        foreach my \@line(@input) {
            push @left,  $line[0];
            push @right, $line[1];
        }
        @left  = sort {$a <=> $b} @left;
        @right = sort {$a <=> $b} @right;

        for (my $i = 0; $i < @left; ++$i) {
            push @dist, abs($left[$i] - $right[$i]);
        }

        return sum0 @dist;
    },
    sub($input_aref) {
        my \@input = $input_aref;
        my %index;
        $index{$_}++ foreach map {$_->[1]} @input;

        return sum0 map {$_ * ($index{$_} // 0)} map {$_->[0]} @input;
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
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
  test: 11
- input: |-
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
  test: 31
