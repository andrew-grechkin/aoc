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
    @tasks = map {{input => $_}} ([@lines], \@lines);
}

sub parse_input_data ($input_aref) {
    my $rule = 1;
    my (@rules, @lines);

    while (defined(my $line = shift @$input_aref)) {
        if (!$line) {$rule = 0; next;}
        if ($rule) {
            push @rules, [split(m/[|]/, $line)];
        } else {
            push @lines, [split(m/,/, $line)];
        }
    }

    return \@rules, \@lines;
}

sub rules_index($rules_aref) {
    my %result;

    foreach my $rule (@$rules_aref) {
        $result{$rule->[0]}{$rule->[1]} = 1;
    }

    return \%result;
}

sub is_line_correct($line_aref, $index_href) {
    my \%index = $index_href;
    my @line = @$line_aref;

    while (@line > 1) {
        my $left = shift @line;
        foreach my $right (@line) {
            return 0 if exists $index{$right} && exists $index{$right}{$left};
        }
    }

    return 1;
}

sub line_fix($line_aref, $index_href) {
    my \%index = $index_href;
    my @line = @$line_aref;

    @line = sort {$a == $b ? 0 : exists $index{$a} && exists $index{$a}{$b} ? -1 : 1} @line;

    return \@line;
}

my @solutions = (
    sub($input_aref) {
        my (\@rules, \@lines) = parse_input_data($input_aref);
        my \%index = rules_index(\@rules);

        my @correct_lines;
        foreach my $line (@lines) {
            push @correct_lines, $line if is_line_correct($line, \%index);
        }

        return sum0 map {my $len = @$_; my $mid = int($len / 2); $_->[$mid]} @correct_lines;
    },
    sub($input_aref) {
        my (\@rules, \@lines) = parse_input_data($input_aref);
        my \%index = rules_index(\@rules);

        my @fixed_lines;
        foreach my $line (@lines) {
            push @fixed_lines, line_fix($line, \%index) unless is_line_correct($line, \%index);
        }

        return sum0 map {my $len = @$_; my $mid = int($len / 2); $_->[$mid]} @fixed_lines;
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
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
  test: 143
- input: |-
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
  test: 123
