#!/usr/bin/perl

use lib qw( ../lib );

use strict;
use warnings;

use Neko::HeatMap;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Test::Simple tests => 2;

my $d = 1; # 0|1 Debugging

my $configFile = '../t/TestConfig.conf';

my $HeatMap = new Neko::HeatMap( );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim new : \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}

$HeatMap->setConfig( 'file' => $configFile );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim setConfig : \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}

my $Config = $HeatMap->getConfig();

print Dumper($Config) if $d;
print $Config->{'HeatMapUser'}{'language'}."\n" if $d;

if ( $HeatMap->hasErrors() ) {
    print "Fehler beim 1. Config holen: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}
else { 
    if ( $Config->{'HeatMapUser'}{'language'} eq 'de' ) {
        ok ( 1 == 1 ) ;
    }
    else {
        ok ( 1 == 2 );
        exit 2;
    }
}



# ============================
# Das Ganze nochmal mit selbst gesetzter Config

my $params = {
                 'HeatMap' => { 'x' => 100 },
                 'HeatMapUser' => { 'language' => 'en' },
             };
$HeatMap->setConfig( 'params' => $params );
if ( $HeatMap->hasErrors() ) {
    print "Fehler beim setConfig : \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}

my $Config2 = $HeatMap->getConfig();

print Dumper($Config2) if $d;
print $Config2->{'HeatMapUser'}{'language'}."\n" if $d;

if ( $HeatMap->hasErrors() ) {
    print "Fehler beim 2. Config holen: \n". join("\n", @{ $HeatMap->hasErrors()} )."\n";
    ok ( 1 == 2 );
    exit 1;
}
else { 
    if ( $Config2->{'HeatMapUser'}{'language'} eq 'en' ) {
        ok ( 1 == 1 ) ;
    }
    else {
        ok ( 1 == 2 );
        exit 2;
    }
}
exit 0;
