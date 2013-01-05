#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw/time/;

my %sorts = ( Mergesort => 'mergesort.js', Default => 'default.js', Quicksort => 'quicksort.js' );
my %algorithm_source = ();

#Generates JavaScript array with defined size and maximum size of it's elements
sub generate_js_array($ $) {
    my ($size, $max) = @_;
    my $array = 'var array = [';
    map { $array .= rand($max) . ",\n" } (0..$size);
    chop($array);
    chop($array);
    $array .= '];';
    return $array;
}

#Creates a new test for given sort type and array
sub create_test($ $) {
    my ($sort_type, $array) = @_;
    my $sort_algorithm = $algorithm_source{$sort_type};
    my $test_case = "$array\n$sort_algorithm";
    return $test_case;
}

#Saves the test in a file into the temp directory
sub save_test_case($ $ $) {
    my ($test_case, $sort_type, $i) = @_;
    my $filename = "./temp/$sort_type-$i.js";
    open(FH, ">$filename");
    print FH $test_case;
    close(FH);
    return $filename;
}

#Runs the test and measures the runtime
sub run_test_case($) {
    my $filename = shift;
    my $time = time();
    `d8 $filename`;
    return time() - $time;
}

#Tests an algorithm with given array
sub test_algorithm($ $ $) {
    my ($sort_type, $array, $test_count) = @_;
    my ($test_case, $filename, $performance);
    $test_case = create_test($sort_type, $array);
    $filename = save_test_case($test_case, $sort_type, $test_count);
    print "Running the test case...\n";
    $performance = run_test_case($filename);
    #unlink($filename);
    print "Cleaning the trash...\n";
    return $performance;
}

#Gets the source of an algorithm from the algorithms folder
sub get_algorithm($) {
    my $sort_type = shift;
    my $file = $sorts{$sort_type};
    my $result = '';
    open(FH, "<./algorithms/$file");
    while (<FH>) {
        $result .= $_;
    }
    close(FH);
    return $result;
}

#Caches all algorithms into a hash with keys the algorithm name and value the algorithm
sub cache_algorithms_source {
    for my $algorithm (keys(%sorts)) {
        $algorithm_source{$algorithm} = get_algorithm($algorithm);
    }
}

#Tests all algorithms with different arrays and tests count
sub test_algorithms($ $ $) {
    my ($tests_count, $size, $max) = @_;
    my %result = ();
    my ($array, $count);
    for (my $i = 0; $i < $tests_count; $i += 1) {
        $array = generate_js_array($size, $max);
        $count = $i + 1;
        for my $algorithm (keys(%sorts)) {
            print "Running $algorithm test number $count...\n";
            $result{$algorithm} = [] unless defined($result{$algorithm});
            push(@{$result{$algorithm}}, test_algorithm($algorithm, $array, $i));
        }
    }
    return \%result;
}

#Builds a CSV string from the results
sub build_csv($) {
    my $result = shift;
    my %result = %$result;
    my @algorithms = keys(%result);
    my $current;
    my @current_result;
    my $data = '';
    print "Building a CSV statistics...\n";
    for (my $i = 0; $i < scalar(@algorithms); $i += 1) {
        $current = $algorithms[$i];
        $data .= $current . ',';
        @current_result = @{$result{$current}};
        for (my $j = 0; $j < scalar(@current_result); $j += 1) {
            $data .= $current_result[$j];
            if ($j < scalar(@current_result) - 1) {
                $data .= ',';
            }
        }
        $data .= "\n";
    }
    return $data;
}

MAIN: {
    my $max = 100;
    my $array_size = 1000000;
    my $tests_count = 50;
    print "Starting $tests_count test cases for all
algorithms (" . join(', ', keys(%sorts)) . ") with parementers: 
arrays with size $array_size, maximum size of each element $max.\n";

    cache_algorithms_source();
    my $result = test_algorithms($tests_count, $array_size, $max);
    my $csv_result = build_csv($result);

    open(FH, '>result.csv');
    print FH $csv_result;
    close(FH);
    print "Exiting\n";
}
