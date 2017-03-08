#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);


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


my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

make_dir ($sh_path);
make_dir ($output_path);

my %info;
my $sh_file = sprintf ('%s/%s', $sh_path, "cnvkit.$sample.$option.sh");
read_config ($config_file, \%info);

#####Requirement
my $reference = $info{reference};
my $access_bed = $info{access_bed};
my $refFlat_txt = $info{refFlat_txt};
my $delivery_tbi_id = $info{delivery_tbi_id};
my %id_hash;
match_id ($delivery_tbi_id, \%id_hash);

my $delivery_id = $id_hash{$sample};


my $bam_path = "$output_path/delivery_bam/";
make_dir ($bam_path);
my $input_bam = "$bam_path/delivery_bam/$delivery_id.bam";
my $input_bai = "$bam_path/delivery_bam/$delivery_id.bam.bai";

my $orig_bam = "$input_path/$sample/Projects/default/default/sorted.bam";
my $orig_bai = "$input_path/$sample/Projects/default/default/sorted.bam.bai";

#######
open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N cnvkit.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";

printf $fh_sh ("ln -s %s %s \n", $orig_bam, $orig_bai);
printf $fh_sh ("ln -s %s %s \n", $input_bam, $input_bai);
printf $fh_sh ("%s batch -m wgs %s -n -f %s -g %s --annotate %s -output-reference %s -d %s\n", $program, $input_bam, $reference, $access_bed, $refFlat_txt, "$output_path/$delivery_id.cnn", $output_path);

printf $fh_sh ("%s call %s -m threshold -t=-1.1,-0.4,0.3,0.7 -o %s \n", $program, "$output_path/$delivery_id.cns", "$output_path/$delivery_id.call.cns");
printf $fh_sh ("%s gainloss %s -s %s -t 0.4 -m 5 > %s\n", $program, "$output_path/$delivery_id.cnr", "$output_path/$delivery_id.call.cns", "$output_path/$delivery_id.gene.gainloss.txt");

printf $fh_sh ("%s scatter %s -s %s -o %s \n", $program, "$output_path/$delivery_id.cnr", "$output_path/$delivery_id.cns", "$output_path/$delivery_id-scatter.pdf");
printf $fh_sh ("%s diagram %s -s %s -o %s \n", $program, "$output_path/$delivery_id.cnr", "$output_path/$delivery_id.cns", "$output_path/$delivery_id-diagram.pdf");

printf $fh_sh ("convert -density 150 %s -quality 90 %s \n", "$output_path/$delivery_id-scatter.pdf", "$output_path/$delivery_id-scatter.png");
printf $fh_sh ("convert -density 150 %s -qaulity 90 %s \n", "$output_path/$delivery_id-diagram.pdf", "$output_path/$delivery_id-diagram.png");

print $fh_sh; "date\n";
close $fh_sh;

cmd_system ($sh_path, $hostname, $sh_file);

sub match_id {
    my ($id_list, $hash_ref) = @_;
    my @id_array = split /\,/, $id_list;
    foreach my $id (@id_arrary){
        my ($delivery_id, $tbi_id, $type) = split /\:/, $id;
        $hash_ref->{$tbi_id}=$delivery_id;
    }
}

