#!/usr/bin/perl

use lib qw( ../lib );

use strict;
use warnings;

use Neko::HeatMap;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Test::Simple tests => 2;

my $d = 0; # 0|1 Debugging

my $csvFile1 = '../t/TestData1.csv';
my $csvFile2 = '../t/TestData2.csv';
my $csvFile3 = '../t/TestData3.csv';
my $kw = 53;
my @files1 = [$csvFile1, $csvFile2];
my @files2 = [$csvFile2, $csvFile3];
my @files3 = [$csvFile3, $csvFile1];

# pick line 10 and count
my @resultsAnz = ( 54, 53, 54 );
# pick 5th elt in line10
my @resultsVal = ( '53,37', '2.052,22', '-10' );

my $HeatMap = new Neko::HeatMap( );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim new holen: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}
ok ( 1 == 1 );

my $error = 0;
foreach my $files ( @files1, @files2, @files3 )
{
    $HeatMap->parseData ( 'files' => $files, 'kw' => $kw );
    if ( $HeatMap->hasErrors() ) {
        print "Fehler beim daten parsen holen: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
        ok ( 1 == 2 );
        exit 1;
    }
    
    my $parsedData = $HeatMap->getParsedData();
    
    # check
    my $l = @{$parsedData}[10];
    my $s = scalar( @{$l} );
    my $elt = @{$l}[5];
    my $c1 = shift @resultsAnz;
    my $c2 = shift @resultsVal;

    if ( $s != $c1 ) {
        print "Fehler beim daten parsen\nFiles: @{$files}:\nAnzahl Felder erwartet: $c1 - bekommen: $s\n";
        $error = 1;
    }
    if ( $elt ne $c2 ) {
        print "Fehler beim daten parsen\nFiles: @{$files}:\nElement Zeile 10, Feld 5 erwartet: $c2 - bekommen: $elt\n";
        $error = 1;
    }

}

ok ( 1 == 2 ) if $error;
ok ( 1 == 1 ) if !$error;


exit 0;
