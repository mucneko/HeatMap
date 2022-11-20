#!/usr/bin/perl

use lib qw( ../lib );

use strict;
use warnings;

use Neko::HeatMap;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Test::Simple tests => 2;

my $d = 0; # 0|1 Debugging

my $ColorFile = '../t/TestColor.Map';
my $startColorMap = {
-10 => [ 255, 255, 255 ], # keine Angabe
 0 => [ 210, 255, 210 ],
10 => [ 175, 255, 175 ],
20 => [ 0, 255, 0 ], #grün
30 => [ 175, 255, 0 ], #gelb
};


my $HeatMap = new Neko::HeatMap( );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim new holen: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}

$HeatMap->setColorMap( 'map' => $startColorMap );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim setColorMap: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 2;
}


my $colorMap = $HeatMap->getColorMap();

print Dumper($colorMap) if $d;

if ( $HeatMap->hasErrors() ) {
    print "Fehler beim 1. getColorMap \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}
else {
    if ( $colorMap->{'10'}[2] == 175 ) {
        ok ( 1 == 1 ) ;
    }
    else {
        print "Fehler beim 1. getColorMap unerwarteter Wert in der MusterMap: $colorMap->{'10'}[2]\n";
        ok ( 1 == 2 );
        exit 2;
    }
}


# und jetzt noch andersrum
$HeatMap->setColorMap( 'file' => $ColorFile );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim 2. setColorMap: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 2;
}

$colorMap = $HeatMap->getColorMap();

print Dumper($colorMap) if $d;

if ( $HeatMap->hasErrors() ) {
    print "Fehler beim 2. getColorMap \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}
else {
    if ( $colorMap->{'10'}[1] == 255 ) {
        ok ( 1 == 1 ) ;
    }
    else {
        print "Fehler beim 2. getColorMap unerwarteter Wert in der MusterMap: $colorMap->{'10'}[1]\n";
        ok ( 1 == 2 );
        exit 2;
    }
}

exit 0;
