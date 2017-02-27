#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Utils;
use Exporter qw(import);
our @EXPORT_OK = qw(read_config trim checkFile checkDir make_dir cp_file);
#############################################################
##sub
##############################################################
sub read_config{
    my ($config, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $config or die;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
        $hash_ref->{$key}=$value;
    }
    close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result : $result[0];
}

sub checkDir {
    my $dir = shift;
    if (!-d $dir){
        die "error! Not found directory <$dir>";
    }
}

sub checkFile {
    my $file = shift;
    if (!-f $file) {
        die "error! Not found <$file> \n";
    }
}

sub make_dir {
    my $dir = shift;
    if (!-d $dir){
        my $cmd = "mkdir -p $dir";
        system($cmd);
    }
}

sub cp_file {
    my ($orig, $target) = @_;
    checkFile($orig);
    my $cp_cmd = "cp $orig $target";
    system($cp_cmd);
}
1;
