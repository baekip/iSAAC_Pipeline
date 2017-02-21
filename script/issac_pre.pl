#!/usr/bin/perl 

#lane1_read1.fastq.gz lane1_read2.fastq.gz lane2_read1.fastq.gz lane2_read2.fastq.gz

use strict;
use warnings;

use Getopt::Long;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/../library';
use Utils qw(make_dir checkFile);


my ($program, $input_path, $sample, $log_path, $output_path, $threads, $config);
GetOptions (
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample|s=s' => \$sample,
    'log_path|l=s' => \$log_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$threads,
    'config_file|c=s' => \$config,
);

#perl issac_pre.pl
#00,rawdata/TN1610D1351 -> result/01-1_issac_pre/TN1610D1351
#-i,input_path /BiO/BioPeople/baekip/BioPipeline/WGS_ISAAC_Pipeline/example 
#-s,sample_list TN1610D1351 
#-o, output_path 
#

my $sh_path = printf ("%s/%s", $log_path, $sample);
my $sh_file = printf ("%s/%s", $sh_path, "issac_pre.$sample.sh");
make_dir($sh_path);
open my $fh_sh, '>', $sh_file or die;

my @fastq_R1_list = glob ("$input_path/$sample/*_R1.{fastq,fq}");
my @fastq_R2_list = glob ("$input_path/$sample/*_R2.{fastq.fq}");

if (@fastq_R1_list != @fastq_R2_list){
    die "ERROR: check your rawdata file <$input_path>";
}else{
    for (my $i=1; $i<@fastq_R1_list; $i++) {
        my $isaac = "$output_path/lane$i\_read1.fastq.gz";
        printf $fh_sh ("ln -s %s %s \n", $fastq_R1_list[$i], $isaac);
    }
    for (my $i=1; $i<@fastq_R2_list; $i++) {
        my $isaac = "$output_path/lane$i\_read2.fastq.gz";
        printf $fh_sh ("ln -s %s %s \n", $fastq_R2_list[$i], $isaac);
    }
}

close $fh_sh;
system ("bash $sh_file");


#ln_file_1 ($input_path, \@fastq_R1_list, $output_path, $sh_file);
#ln_file_2 ($input_path, \@fastq_R2_list, $output_path, $sh_file);
#
#sub ln_file_1 {
#    my ($input, $list, $output, $sh) = @_;
#        for (my $i=1; $i<@$list; $i++){
#            my $isaac  = "lane$i\_read1.fastq.gz";
#            printf  
#    }
#}
#
#sub ln_file_2 {
#    my ($input, $list, $output, $sh) = @_;
#        for (my $i=1; $i<@$list; $i++){
#            my $isaac = "lane$i\_read2.fastq.gz";
#    }
#}
#            
