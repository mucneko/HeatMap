#!/usr/bin/perl

use lib qw( ../lib );

use strict;
use warnings;

use Neko::hmFunctions;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Test::Simple tests => 1;

my $d = 0; # 0|1 Debugging

my $ColorFile = '../t/TestColor.Map';

my %erg = hmF_loadColorMap($ColorFile);

print Dumper(\%erg) if $d;

if ( scalar ( @{$erg{'errormsg'}} ) ) {
    print "Fehler beim File laden: \n". join("\n", @{$erg{'errormsg'}} )."\n";
    ok ( 1 == 2 );
    exit 1;
}
else { 

    my $colorMap = $erg{'colorMap'};
    if ( $colorMap->{'10'}[1] == 255 ) {
        ok ( 1 == 1 ) ;
    }
    else {
        ok ( 1 == 2 );
        print "Datenblob passt nicht: \n". Dumper(\%erg)."\n";
        exit 2;
    }
}

exit 0;
