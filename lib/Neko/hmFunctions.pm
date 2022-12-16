#!/usr/bin/perl

package Neko::hmFunctions;

use strict;
use warnings;

use Math::Round qw( nearest nlowmult );
use Data::Dumper;

use Imager;
use Imager::Fill;

# Debugging
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Config::Tiny;

our (@ISA, @EXPORT);

@ISA = qw(Exporter);

@EXPORT = qw( 
              hmF_getConfig
              hmF_loadColorMap
              hmF_cleanupData
            );

my $d = 0; #Debuginf 0|1

# get Config and return
# my %hash = hmF_getConfig( <file> )
sub hmF_getConfig
{

    my $configFile = shift // '';

    my $config = '';

    my %erg = (
             'errormsg' => [],
    );

    # Configfile bestimmen
    if ( -f $configFile ){
        $config = Config::Tiny->read( $configFile, 'encoding(iso-8859-1)') || push ( @{$erg{'errormsg'}}, "Kann Config aus File $configFile nicht laden: $!" );
        $erg{'used_configfile'} = $configFile;
    }
    else {
        push ( @{$erg{'errormsg'}}, "Configfile $configFile nicht gefunden." );
    }

    if ( $config ) {
        $erg{'config'} = $config;
    }

print "Neko::hmFunctions::hmF_getConfig returne: ".Dumper(\%erg) if $d;

    return %erg;
}

# get filecontent and return COLORMAP
# my $hasref = hmF_loadColorMap( <file> )
sub hmF_loadColorMap
{
    my $file = shift // '';

    my %erg = (
             'errormsg' => [],
    );

    if ( -f $file ) {
        our $COLOR_MAP;
        require $file; 
        $erg{'colorMap'} = $COLOR_MAP;
    }
    else { push ( @{$erg{'errormsg'}}, "Neko::hmFunctions::hmF_loadColorMap $file nicht gefunden." ); }

    return %erg;
}

# my $cnt = hmF_cleanupData($feld);
sub hmF_cleanupData
{
    my $feld = shift // '';

    # bei den Inzidenzen putzen, die kommen als 1.234,56
    # oder als 1,234.56
    if ( $feld =~ /[0-9]\,[0-9]{2}$/ ) {
        $feld =~ s/\.//g;
        $feld =~ s/\,/\./g;
    }
    elsif ( $feld =~ /[0-9]\.[0-9]{2}$/ ) {
        $feld =~ s/\,//g;
    }

    return $feld;
}
# ##############################################
1;
