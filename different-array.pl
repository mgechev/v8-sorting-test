#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw/time/;

#Defines all sorting algorithms required for the given test case
my %ALGORITHMS = ( heapsort => 'heapsort.js', default => 'default.js' );

#Generates a JavaScript array with random values
#with max size equals to the second parameter of the function
#and size equals to the first parameter of the function
sub generate_js_array($ $) {
    my ($size, $max) = @_;
    my $array = 'var array = [';
    map { $array .= rand($max) . ",\n" } (0..$size);
    chop($array);
    chop($array);
    $array .= '];';
    return $array;
}

#Reads and returns a given algorithm's souce
sub get_search_algorithm($) {
    my $sort_type = shift;
    my $file = $ALGORITHMS{$sort_type};
    my $result = '';
    open(FH, "<./algorithms/$file");
    while (<FH>) {
        $result .= $_;
    }
    close(FH);
    return $result;
}

#Creates a test case for given sorting algorithm
#with given size of the array and max element size
sub create_test($ $ $) {
    my ($sort_type, $size, $max) = @_;
    my $array = generate_js_array($size, $max);
    my $sort_algorithm = get_search_algorithm($sort_type);
    my $test_case = "$array\n$sort_algorithm";
    return $test_case;
}

#Saves the generated test case
sub save_test_case($ $ $) {
    my ($test_case, $sort_type, $i) = @_;
    my $filename = "./temp/$sort_type-$i.js";
    open(FH, ">$filename");
    print FH $test_case;
    close(FH);
    return $filename;
}

#Runs a single test case and returns
#the time required for running it
sub run_test_case($) {
    my $filename = shift;
    my $time = time();
    `d8 $filename`;
    return time() - $time;
}

#Tests N times given algorithm with given array size and
#given max size of their elements
sub test_algorithm($ $ $ $) {
    my ($sort_type, $tests_count, $size, $max) = @_;
    my ($test_case, $filename, $performance, $count);
    my @histogram = ();
    for (my $i = 0; $i < $tests_count; $i += 1) {
        $count = $i + 1;
        print "Running test number $count for $sort_type...\n";
        print "Generating a random array...\n";
        $test_case = create_test($sort_type, $size, $max);
        $filename = save_test_case($test_case, $sort_type, $i);
        print "Running the test case...\n";
        push(@histogram, run_test_case($filename));
        unlink($filename);
        print "Cleaning the trash...\n";
    }
    return \@histogram;
}

#Tests N times all algorithms with given size for the array
#and given max value for the random array elements
sub test_algorithms($ $ $) {
    my ($tests_count, $size, $max) = @_;
    my %result = ();
    for my $algorithm (keys(%ALGORITHMS)) {
        print "Running $algorithm tests...\n";
        $result{$algorithm} = test_algorithm($algorithm, $tests_count, $size, $max);
    }
    return \%result;
}

#Builds an CSV string by hash with keys the sorting algorithms
#and values time statistics
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
    my $array_size = 100000;
    my $tests_count = 50;
    print "Starting $tests_count test cases for all algorithms (" . keys(%ALGORITHMS) . " total) with parementers: arrays with size $array_size, maximum element $max.\n";
    my $result = test_algorithms($tests_count, $array_size, $max);
    my $csv_result = build_csv($result);

    open(FH, '>result.csv');
    print FH $csv_result;
    close(FH);
    print "Exiting\n";
}
