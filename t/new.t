#!/usr/bin/perl

use lib qw( ../lib );

use strict;
use warnings;

use Neko::HeatMap;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Test::Simple tests => 2;

my $configFile = '../t/TestConfig.conf';
my $HeatMap = new Neko::HeatMap( testlauf => 'test', 'configFile' => $configFile );

if ( $HeatMap->hasErrors() ) {
    print "Fehler beim HeatMap laden: \n". join("\n", @{ $HeatMap->hasErrors() } )."\n";
    ok ( 1 == 2 );
    exit 1;
}
else { ok ( 1 == 1 ); }

# Config ist auch da?
my $HMConfig = $HeatMap->{'Config'};
if ( $HMConfig->{'HeatMapUser'}{'language'} eq 'de' ) {
     ok ( 1 == 1 );
}
else {
    print "Config fehlt: ".Dumper( $HeatMap->{'Config'} );
    print Dumper( $HeatMap );
    ok ( 1 == 2 );
}

exit 0;
