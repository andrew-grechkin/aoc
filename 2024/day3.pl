#!/usr/bin/env perl

use v5.40;
use experimental qw(class declared_refs defer refaliasing);

use Getopt::Long qw(:config auto_version bundling no_ignore_case);
use List::Util   qw(all pairs sum0);

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
    @tasks = map {{input => [split(m/\R/, $_->{input})], test => $_->{test}}} @data;
} else {
    chomp(my @lines = <<>>);
    @tasks = map {{input => $_}} (\@lines, \@lines);
}

my @solutions = (
    sub($input_aref) {
        my \@input = $input_aref;

        my $data = join '', @input;
        my @muls = pairs $data =~ m/mul[(](\d+),(\d+)[)]/g;

        return sum0 map {$_->[0] * $_->[1]} @muls;
    },
    sub($input_aref) {
        my \@input = $input_aref;

        my $data = join('', @input) =~ s/don\'t[(][)].*?(?:do[(][)]|$)//gr;
        my @muls = pairs $data      =~ m/mul[(](\d+),(\d+)[)]/g;

        return sum0 map {$_->[0] * $_->[1]} @muls;
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
    xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
  test: 161
- input: |-
    xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
  test: 48
