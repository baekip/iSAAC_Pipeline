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

my ($config, $pipeline, $help);
GetOptions (
    'config=s' => \$config,
    'pipeline=s' => \$pipeline,
    'help=s' => \$help
);

die `pod2text $0` if (!defined $config || !defined $pipeline || $help);

my %info;
read_config ($config, \%info);
#my %pipe;
#read_pipeline ($pipeline, \%pipe);

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
my @sample_list = split /\,/, $sample_id;
checkDir ($script_path);
make_dir($result_path);
make_dir($report_path);

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

foreach my $row (@pipe_list){
    my ($order, $input_order, $program, $option, $sample, $threads) = split /\s+/, $row;
    if ($option =~ /,/){
        my @option_list = split /\,/, $option;
        $option = $option_list[0];
    }
    my $folder_name = sprintf ("%s/%s_%s_%s", $result_path, $order, $program, $option);
    print $folder_name."\n";
}


#perl issac_pre.pl -p program -i input_path -s sample -l $log_path -o $output_path -t $thrads -c $config; 

#sub program_run {
#    my ($program, $input_path, $sample, $log_path, $output_path, $threads, $config) = @_;
#    
#    my $sh_path = "$log_path/$sample_id";
#    mdkir_dir ($sh_path);
#    
#
#    my $run_cmd = "perl $program -i $input_path -s $sample -l $log_path -o $output_path -t $threads -c $config";
#    system ($run_cmd);
#
#}






#sub run_pipeline {
#    my ($dic_flow_pipeline, $list_flow_pipeline, $config_file, $pipeline_file) = @_;
    

#sub program_run {
#    my ($list_run, $list_sample_id, $program_script, $project_log_write_fp);
#    print "\n";
#    print "=======================================================\n";
#    print "-------START : $program_
#


