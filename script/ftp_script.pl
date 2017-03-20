#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);

my ($input, $output, $option); 

GetOptions (
    'input_vcf|i=s' => \$input,
    'output|o=s' => \$output,
    'config|c=s' => \$config,
);

my %info;
read_config ($config, \%info);
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;

foreach my $id (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    ##00_report
    my $ftp_in_0_1 = "$in_0_1/";
    my $ftp_in_0_2 = "$in_0_2/";
    ##01_variant_report
    my $ftp_out_0_1 = "$output/00_report/01_variant_report";
    ##02_sv_report
    my $ftp_out_0_2 = "$output/00_report/02_sv_report";
    
    ##01_fastq_file
    my $ftp_in_1 = "$in_1/$tbi_id/";
    my $ftp_out_1 = "$output/01_fastq_file/$delivery_id/";
    SoftLink ($ftp_in, $ftp_out);

    ##02_bam_file
    my $ftp_in_2 = "$in_2/$tbi_id/";
    my $ftp_out_2 = "$output/02_bam_file/$delivery_id/";
    SoftLink ( $ftp_in_2, $ftp_out_2);

    ##03_vcf_file
    my $ftp_in_3 = "$in_3/$tbi_id/";
    my $ftp_out_3 = "$output/03_vcf_file/$delivery_id/";
    SoftLink ( $ftp_in_3, $ftp_out_3);

    ##04_annotation_file
    my $ftp_in_4 = "$in_4/$tbi_id/";
    my $ftp_out_4 = "$output/04_annotation_file/$delivery_id/";
    SoftLink ( $ftp_in_4, $ftp_out_4);

    ##05_cnv_file
    my $ftp_in_5 = "$in_5/$tbi_id/";
    my $ftp_out_5 = "$output/05_cnv_file/$delivery_id/";
    SoftLink ( $ftp_in_5, $ftp_out_5);

    ##06_sv_file
    my $ftp_in_6 = "$in_6/$tbi_id/";
    my $ftp_out_6 = "$output/06_sv_file/$delivery_id/";
    SoftLink ( $ftp_in_6, $ftp_out_6);

}


sub cp_file {
    my ($in_file, $out_file) = @_;
    checkFile($in_file);
    make_dir($out_file);
    my $cp_cmd = "cp $in_file $out_file";
    system ($cp_cmd);
}

sub SoftLink{
    my ($in_file, $out_file) = @_;
    checkFile($in_file);
    my $link_cmd = "ln -s $in_file $out_file";
    system ($link_cmd);
}
