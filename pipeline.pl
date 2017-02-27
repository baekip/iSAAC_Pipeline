#!/usr/bin/perl

=head1 Name
    
    pipeline.pl -- iSAAC WGS pipeline script

=head1 Version
    
    Author: baekip (inpyo.baek@theragenetex.com)
    Version: 0.1
    Date: 2017-02-21

=head1 Usage

    perl pipeline.pl [option] file
        -c: input config <wgs.config.txt>
        -p: input pipeline <wgs.pipeline.txt>
        -h: output help information to screen

=head1 Subscript

    - isaac_pre.pl, 2017-02-21
    - fastqc.pl, 2017-02-22
    - isaac.pl, 2017-02-22
    - starling_pre.pl, 2017-02-23
    - starling.pl, 2017-02-23
    - gvcftools.pl, 2017-02-23
    - qualimap.pl, 2017-02-24

=head1 Example

    perl pipeline -c wgs.config.txt -p wgs.pipeline.txt

=cut

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/library';
use Utils qw (read_config checkFile make_dir checkDir trim);
use Queue qw (CheckQsub pipe_arrange program_run);

my ($config, $pipeline, $help);
GetOptions (
    'config=s' => \$config,
    'pipeline=s' => \$pipeline,
    'help=s' => \$help
);

$pipeline = (abs_path $pipeline);
$config  = (abs_path $config);

die `pod2text $0` if (!defined $config || !defined $pipeline || $help);

my %info;
read_config ($config, \%info);

#############################################################
#Requirement config source 
#############################################################

my $pipeline_path = dirname (abs_path $0);
my $script_path = "$pipeline_path/script/";
my $project_path = $info{project_path};
my $rawdata_path = $info{rawdata_path};
my $result_path = $info{result_path};
my $report_path = $info{report_path};
my $project_id = $info{project_id};
my $sample_id = $info{sample_id};
my $sh_path = sprintf ('%s/sh_log_file', $result_path);
my $flag_orig_path = sprintf ('%s/flag_file/', $result_path);
my @sample_list = split /\,/, $sample_id;
checkDir ($script_path);
make_dir($result_path);
make_dir($report_path);
make_dir($sh_path);
#make_dir($flag_orig_path);

#############################################################
#Requirement config source 
#############################################################

read_pipeline_config ($config, $pipeline);
use Data::Dumper;

my @pipe_list;
sub read_pipeline_config{
    my ($config_config, $pipeline_config) = @_;
    open my $fh_pipe, '<:encoding(UTF-8)', $pipeline_config or die;
    while (my $row = <$fh_pipe>){
        chomp $row;
        if ($row =~ /^#|^\s+/) {next;}
        if (length $row == 0) {next;}
        push @pipe_list, $row;
    }
    close $fh_pipe;
}

my %pipe_hash;
pipe_arrange ($pipeline, \%pipe_hash);

my $startdatestring = localtime();
print "-------------------------------------------------------\n";
print "START Pipeline: $startdatestring\n";
print "-------------------------------------------------------\n";

foreach my $row (@pipe_list){
    my $input_path;
    my ($order, $input_order, $program, $option, $type, $threads) = split /\s+/, $row;
    if ($option =~ /,/){
        my @option_list = split /\,/, $option;
        $option = $option_list[0];
    }else{ }

    if ($input_order =~ /,/){
        my @input_list = split /\,/, $input_order;
    }else{ }

    if ($input_order eq '00'){ 
        $input_path = $rawdata_path; 
    }else {
        $input_path = sprintf ("%s/%s", $result_path, $pipe_hash{$input_order});
    }
   
###flag start
    my $script = sprintf ("%s/%s.pl", $script_path, $program);
    my $output_path = sprintf ("%s/%s/", $result_path, $pipe_hash{$order});
    my $sh_program_path = sprintf ("%s/%s/", $sh_path, $pipe_hash{$order});
    my $flag_in = sprintf ("%s/%s/%s_flag.txt", $flag_orig_path, $pipe_hash{$order}, $pipe_hash{$order});
    my @flag_list;
    my $datestring=localtime();
    
    print "#process: $order-$program\n"; 
    
    if (-e $flag_in){
        open my $fh_in, '<:encoding(UTF-8)', $flag_in or die;
        while (my $row = <$fh_in>){
            chomp $row;
            push @flag_list, $row;
        }close $fh_in;
    }
    my %flag_hash = map {$_ => 1} @flag_list;
    my @run_sample = grep (!defined $flag_hash{$_}, @sample_list);
    my @exist_sample = grep ($flag_hash{$_}, @sample_list);
    if (@run_sample == 0) {
        print "-------------------------------------------------------\n";
        print "Exist Flag $order: $datestring\n";
        print "-------------------------------------------------------\n";
        next;
    }

    my @job_list;
    my @run_list; 
    
    my $flag_path = sprintf ("%s/%s/", $flag_orig_path, $pipe_hash{$order});
    make_dir($flag_path);
    my $flag_file = sprintf ("%s/%s_flag.txt", $flag_path, $pipe_hash{$order});
    open my $fh_flag, '>', $flag_file or die;
    
    foreach my $sample (@run_sample){
        if ($type eq 'private'){
            my $program_bin = 'perl_script';
            my $cmd = program_run ($script, $program_bin, $input_path, $sample, $sh_program_path, $output_path, $threads, $config);
            my $stdout = qx($cmd);
            my @qlist = split /\s+/, $stdout;
            my $job_id = $qlist[2];
            push @job_list, $job_id;
            push @run_list, @exist_sample, $sample;
        }elsif ($type eq 'public'){
            my $program_bin = $info{$program};
            my $cmd = program_run ($script, $program_bin, $input_path, $sample, $sh_program_path, $output_path, $threads, $config);
            my $stdout = qx($cmd);
            my @qlist = split /\s+/, $stdout;
            my $job_id = $qlist[2];
            push @job_list, $job_id;
            push @run_list, @exist_sample, $sample;
        }else {
            die "ERROR!! Check your pipeline configre <Order Number: $order> type option";
        }
    }
    CheckQsub(@job_list);
    print $fh_flag  join ("\n", sort(@run_list));
    close $fh_flag;
}

