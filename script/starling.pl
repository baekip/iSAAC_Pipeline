#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config);


my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $option, $config_file);
GetOptions (
    'script|S=s' => \$script,
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample_id|S=s' => \$sample,
    'log_path|l=s' => \$sh_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$threads,
    'option|r=s' => \$option,
    'config|c=s' => \$config_file
);


my $host=hostname;
my $queue;
if ( $host eq 'eagle'){
    $queue = 'isaac.q';
}else{
    $queue = 'all.q';
}

make_dir ($sh_path);
make_dir ($output_path);


my %info;
read_config ($config_file, \%info);

my $reference = $info{reference};
my $ivc_config = $info{ivc_config};

my $sh_file = sprintf ('%s/%s', $sh_path, "starling.$sample.sh");

open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N starling_pre.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";
printf $fh_sh ("%s --bam=%s --ref=%s --config=%s --output-dir=%s\n", $program, "$input_path/$sample.bam", $reference, $ivc_config, $output_path);
print $fh_sh "date\n";
close $fh_sh;

system (sprintf ("qsub -V -e %s -o %s -S /bin/bash %s", $sh_path, $sh_path, $sh_file));
