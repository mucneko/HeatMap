#!/usr/bin/perl

package Neko::colorschemes::manageSchemes;



use strict;
use warnings;

use Neko::colorschemes::colorsORIG;
use Neko::HeatMap;

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

    if ( $scheme eq 'orig' ){
        return ORIG_scheme(@_) if $call eq 'scheme';
        return ORIG_buildFarblegende(@_) if $call eq 'buildFarblegende';
        return ORIG_buildCopyright(@_) if $call eq 'buildCopyright';
        return ORIG_buildHeadline(@_) if $call eq 'buildHeadline';
        return ORIG_calculateColor(@_) if $call eq 'calculateColor';
    }
    # fallback assume orig scheme
    else {
        return ORIG_calculateColor(@_) if $call eq 'calculateColor';
    }

}


# ##############################################
1;
