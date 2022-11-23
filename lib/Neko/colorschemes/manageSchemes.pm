#!/usr/bin/perl

package Neko::colorschemes::manageSchemes;

use strict;
use warnings;

use Neko::HeatMap;
use Neko::colorschemes::colorsORIG;
use Neko::colorschemes::schemeEXPERIMENTAL;
use Neko::colorschemes::schemeEASY;

# Debugging
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

our (@ISA, @EXPORT);

@ISA = qw(Exporter);

@EXPORT = qw( 
               schemeFuncs
            );

my $d = 0; #Debuginf 0|1

# my @color = $self->schemeFuncs( 'call' => 'calculateColor',
# 
# additinal options, depending on subroutine
#                        'feld' => "$feld",
#                        'colors' => $colors,
sub schemeFuncs{

    my @proto = @_;
    my $self = shift @proto;
    my %args = @proto;

    my $call = $args{'call'} || Dumper(\%args);
    my $scheme = $self->getScheme();

# print "schemeFuncs: $scheme\n";

    if ( lc( $scheme ) eq 'easy' ){
        return EASY_scheme(@_) if $call eq 'scheme';
        return EASY_buildFarblegende(@_) if $call eq 'buildFarblegende';
        return EASY_buildCopyright(@_) if $call eq 'buildCopyright';
        return EASY_buildHeadline(@_) if $call eq 'buildHeadline';
    }
    if ( lc( $scheme ) eq 'experimental' ){
        return EXP_scheme(@_) if $call eq 'scheme';
        return EXP_buildFarblegende(@_) if $call eq 'buildFarblegende';
        return EXP_buildCopyright(@_) if $call eq 'buildCopyright';
        return EXP_buildHeadline(@_) if $call eq 'buildHeadline';
    }
    # fallback assume orig scheme
    else {
        return ORIG_scheme(@_) if $call eq 'scheme';
        return ORIG_buildFarblegende(@_) if $call eq 'buildFarblegende';
        return ORIG_buildCopyright(@_) if $call eq 'buildCopyright';
        return ORIG_buildHeadline(@_) if $call eq 'buildHeadline';
    }

}


# ##############################################
1;
