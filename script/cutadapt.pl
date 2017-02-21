#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd qw(abs_path);


my ($program, $input_path, $sample, $log_path, $output_path, $treads, $option, $config_file);
GetOptions (
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample_id|s=s' => \$sample,
    'log_path|l=s' => \$log_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$treads,
    'option|r=s' => \$option,
    'config|c=s' => \$config_file
);


print "$input_path$sample\n";
run_program ($input_path, $sample);

sub run_program {
    my ($input_path, $sample) = @_;
#    my ($program, $input_path, $sample, $log_path, $output_path, $threads) = @_;
    
    my @fastq_list = glob("$input_path/$sample/*.{fastq,fq}.gz");
    foreach my $id (@fastq_list){
        
        print $id."\n";
        

    }
}
