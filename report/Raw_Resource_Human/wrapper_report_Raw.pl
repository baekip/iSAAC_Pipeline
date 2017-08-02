use warnings;
use strict;

my $version = "V0.2";

use File::Basename;
use Cwd qw(abs_path);
my $now_script_path = dirname (abs_path $0);
my $script_path = $now_script_path."/Script";

if (@ARGV != 2){
	printUsage();
}

my $general_config_file = $ARGV[0];
my $pipeline_config_file = $ARGV[1];

my %info;
read_general_config( $general_config_file, \%info );

my $Rscript = "Rscript";
my $java = $info{java_1_7};
checkFile( $java );

my $dev_path = $info{dev_path};
my $project_path = $info{project_path};
my $project_id = $info{project_id};

my $out_path = "$project_path/report";
my $text2pdf = "$dev_path/report/etc/text2pdf.jar";
checkFile ( $text2pdf );

my $template_resource_path = "$dev_path/report/Raw_Resource_Human/PDF_Resource"; ###
if (!-d $template_resource_path){
	die "ERROR ! not found template resource directory\n";
}

# make new_path
if (!-d $out_path){
	die "ERROR ! not found report directory in your project_directory <$project_path>\n";
}

# check before reults
my $output_pdf = "$out_path/Analysis_report_".$project_id.".pdf"; #########

`rm -r $out_path/temp\n`;
`rm -r $out_path/resource\n`;
`rm $output_pdf\n`;


=pod
if (-d "$out_path/temp" or -d "$out_path/resource" or -f $output_pdf){
	die "# Warning! Check your before results for making pdf\n".
	"rm -r $out_path/temp\n".
	"rm -r $out_path/resource\n".
	"rm $output_pdf\n";
}
=cut

# copy template resource directory into out_path;
my $resource_path = "$out_path/resource";
my $cmd_copy_template = "cp -rL $template_resource_path $resource_path";
system ($cmd_copy_template) and die "ERROR with".$!."\n";

my $script_0_1 = $script_path."/0-1.parse_kit_type_sh.pl";
checkFile($script_0_1);
my $script_0 = $script_path."/0.parse_project_id.pl";
checkFile( $script_0 );
my $script_1 = $script_path."/1.parse_sample_information.pl";
checkFile( $script_1 );
my $script_2 = $script_path."/2.parse_of_figure.pl";
checkFile( $script_2 );
my $script_6 = $script_path."/6.parse_fastqc_results.pl";
checkFile( $script_6 );

run_script ( $script_0, $general_config_file, "$resource_path/0-1. Cover_page/0-1. c_intro_title.txt" );
#run_script_1 ( $script_0_1, $general_config_file, $pipeline_config_file);
run_script ( $script_1, $general_config_file, "$resource_path/1-1. Sample_Information/1-1 c_table_01.txt" );
run_script_1 ( $script_2, $general_config_file, $pipeline_config_file);
run_script ( $script_6, $general_config_file, "$resource_path/3-1. Results_QualityControls/3.1.1 c_photoMap_01.txt" );
#run_script ( $script_7, $general_config_file, $pipeline_config_file, "$resource_path/3-2. Results_QualityControl/3.2.2 b_photoMap_01.txt" );
#my $cmd_script_8_plot = "$Rscript $script_8_plot \"$project_path/report/alignment.statistics.xls\" \"$resource_path/3-3. Results_Sequence/3.3.1 b_photo_01.PNG\"";
#system($cmd_script_8_plot);
#run_script ( $script_9, $general_config_file, $pipeline_config_file, "$resource_path/3-3. Results_Sequence/3.3.2 c_table_01.txt" );
#my $cmd_script_9_plot = "$Rscript $script_9_plot \"$resource_path/3-3. Results_Sequence/3.3.2 c_table_01.txt\" \"$resource_path/3-3. Results_Sequence/3.3.2 b_photo_01.PNG\"";
#system($cmd_script_9_plot);

# sp : start page 
# hl : header line
# fl : floating line
# ht : header title
# ha : header arrange
# fa : floating arrange
# r : resource folder
# of : output pdf filename



chdir $out_path;
my $user_font_file = "$dev_path/report/etc/Font/SangSangBodyM.ttf";
my $user_CI_file = "$dev_path/report/etc/CI/Theragen_CI.png";
my $cmd_make_pdf = "$java -jar $text2pdf -sp 2 -hl -fl -ht Analysis Report $version -ha r -fa r -r $resource_path -of $output_pdf -f $user_font_file -fi $user_CI_file";
print $cmd_make_pdf."\n";
system($cmd_make_pdf);

sub run_script{
	my ( $script, $config_1,$outfile ) =  @_;
		
	my $command = "perl $script $config_1 > \"$outfile\"";
	print $command."\n";
	system($command);
}

sub run_script_1{
    my ($script, $config, $pipe) = @_;
    my $command = "perl $script $config $pipe";
    print $command."\n";
    system($command);
}

sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub read_general_config{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($key, $value) = split /\=/, $row;
		$key = trim($key);
		$value = trim($value);
		$hash_ref->{$key} = $value;
	}
	close($fh);	
}

sub trim {
	my @result = @_;

	foreach (@result) {
		s/^\s+//;
		s/\s+$//;
	}

	return wantarray ? @result : $result[0];
}

sub printUsage{
	print "Usage: perl $0 <in.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt \n";
	exit;
}
