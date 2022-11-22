#!/usr/bin/perl

use strict;
use warnings;

use lib qw(
            /Users/neko/perl5/lib/perl5/darwin-thread-multi-2level
            /Users/neko/perl5/lib/perl5
            /Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/lib
        );

use Neko::HeatMap;
use Getopt::Std;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben


my $configFile = '';
my $use_this_output_filename = '';
my $kurz = 'MUC';
my $kw = 52;

&usage_and_die() if ($#ARGV < 0);

my %opts;
getopts('c:f:ho:w:', \%opts) || &usage_and_die($_) ;

if ( exists $opts{'h'} ) {
    &usage_and_die();
}
if ( exists $opts{'c'} ) {
    $configFile = $opts{'c'}; 
}
if ( exists $opts{'f'} ) {
    $use_this_output_filename = $opts{'f'}; 
}
if ( exists $opts{'o'} ) {
    $kurz = $opts{'o'}; 
}
if ( exists $opts{'w'} ) {
    $kw = $opts{'w'}; 
}

my @infiles = @ARGV;

# ohne Config wirds nix.
&usage_and_die('Kein Configfile bekommen - Option -c') unless $configFile;

# HeatMap anlegen
my $HeatMap = new Neko::HeatMap( 'configFile' => $configFile );

my $Config = $HeatMap->getConfig();

$HeatMap->setColorMap( 'file' => $Config->{'HeatMapUser'}{'colorMap'} );

# HeatMap Image create
$HeatMap->createImage( 'kuerzel' => $kurz,
                       'infiles' => \@infiles,
                            'kw' => $kw,
                        'scheme' => 'orig'
                     );

# HeatMap Image export
$HeatMap->exportImage( 'filename' => $use_this_output_filename, 
                         'format' => 'gif' 
                     );


# print Dumper( $HeatMap );
print join( "\n", @{ $HeatMap->{'parsedData'}{'lastkw'} } ) ."\n";



# Der Ordnung halber 
sub usage_and_die
{

    my $msg = shift // '';
    print $msg."\n\n" if $msg;

    print <<EOF;

usage: $0 -h
usage: $0 -c [configFile] -o [Orts_Kuerzel] -w [KW_letzte_Reihe] -f [output_filename] CSV_infile1 CSV_infile2

erstellt Heatmap-Image: GIF+JPG+inzidences der lezten Reihe (KW)

Orts_Kuerzel: GER oder MUC - siehe Configteil oben $kurz

wird kein output_filename angegeben, wird einer generiert

CSV_infile1 ist das Basisfile
CSV_infile2 überschreibt bis zum Ende oder bis zu KW infile1

example:
./createHeatmap.pl -o GER -w 2 survstat_GER_2021_2022_01_12_0400/Data.csv survstat_GER_2022_01_12_0400/Data.csv 

results in:

A00..04: 65,80
A05..09: 211,77
A10..14: 246,28
A15..19: 419,37
A20..24: 356,87
A25..29: 326,74
A30..34: 268,30
A35..39: 200,12
A40..44: 199,64
A45..49: 209,34
A50..54: 173,19
A55..59: 134,17
A60..64: 78,47
A65..69: 52,94
A70..74: 21,86
A75..79: 23,27
A80+: 21,43
Storing image as: HeatMap_MUC_2022_01_12_02.gif
Storing image as: HeatMap_MUC_2022_01_12__02.jpeg

Ausgelegt auf Datenquelle: Formular auf survstat.rki.de
Krankheit: Covid-19, Meldejahr, evtl. Ort.
Anzeigeoptionen Alter in 5Jahresintervallen und Kalenderwochen

Inzidenzen ohne Summen
ZIP Downloaden und auspacken.

EOF
    exit 1;
}

exit 0;

