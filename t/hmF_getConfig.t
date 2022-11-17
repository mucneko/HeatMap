#!/usr/bin/perl

use lib qw( ../lib );

use strict;
use warnings;

use Neko::hmFunctions;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Test::Simple tests => 1;

my $d = 0; # 0|1 Debugging

my $configFile = '../t/TestConfig.conf';

my %configErg = hmF_getConfig($configFile);
my $Config = $configErg{'config'};
print Dumper($Config) if $d;
print $Config->{'HeatMapUser'}{'language'}."\n" if $d;

if ( scalar ( @{$configErg{'errormsg'}} ) ) {
    print "Fehler beim Config holen: \n". join("\n", @{$configErg{'errormsg'}} )."\n";
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

exit 0;
