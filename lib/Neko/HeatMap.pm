#!/usr/bin/perl

#OO-Modul
package Neko::HeatMap;

use strict;
use warnings;

# nonOO-Helper
use Neko::hmFunctions;
use Neko::colorschemes::manageSchemes;

use Math::Round qw( nearest nlowmult );

use Imager;
use Imager::Fill;

# Debugging
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben


my $d = 1; # Debugging 0|1

=head1 NAME

NEKO::HeatMap - OO-HeatMap-Modul create a HeatMap Image

=cut

our (@ISA);

@ISA = qw( Neko );


# Constructor
sub new() {
    my $proto = shift;
    my %args  = @_ ;

    my $class = ref($proto) || $proto;
    my $self  = {};

    foreach my $k (keys %args){
        $self->{$k} = $args{$k};
    }

    # $self->{'error'} = 1;
    # push @{$self->{'errormsg'}}, 'Fehlertext';
    $self->{'errormsg'} = ();

    bless $self, $class;

    if ( $self->{'configFile'} ) {
        my %config = hmF_getConfig( $self->{'configFile'} );
        if ( scalar ( @{ $config{'errormsg'} } ) ) {
            push @{$self->{'errormsg'}}, @{ $config{'errormsg'} };
        }
        else {
            $self->{'Config'} = $config{'config'};
        }
    }

    return $self;
}

sub getConfig {
    my $self = shift;
    return $self->{'Config'};
}

# $HeatMap->setConfig( 'file' => 'filename');
# $HeatMap->setConfig( 'params' => \%config );
sub setConfig {
    my $self = shift;
    my %args  = @_ ;
    if ( $args{'file'} ) {
        my %config = hmF_getConfig( $args{'file'} );
        if ( scalar ( @{ $config{'errormsg'} } ) ) {
            push @{$self->{'errormsg'}}, @{ $config{'errormsg'} };
        }
        else {
            $self->{'Config'} = $config{'config'};
        }
    }
    elsif ( $args{'params'} ) {
        $self->{'Config'} = $args{'params'};
    }
    $self->{'Config'};
}

sub getColorMap {
    my $self = shift;
    return $self->{'ColorMap'};
}

# $HeatMap->setColorMap( 'file' => 'filename');
# $HeatMap->setColorMap( 'map' => \%map );
sub setColorMap {
    my $self = shift;
    my %args = @_;

    if ( $args{'file'} ){
        my %erg = hmF_loadColorMap( $args{'file'} );

        if ( scalar ( @{ $erg{'errormsg'} } ) ) {
            push @{$self->{'errormsg'}}, @{ $erg{'errormsg'} };
            return;
        }

        $self->{'ColorMap'} = $erg{'colorMap'} ;
    }

    elsif ( $args{'map'} ) {
        $self->{'ColorMap'} = $args{'map'} ;
    }

    else {
        push @{$self->{'errormsg'}}, "HeatMap::setColorMap unbekannter Parameter. Erwartet: 'map' oder 'file'" ;
    }
}


sub setError {
    my $self = shift;
    my $msg = shift;
    push @{ $self->{'errormsg'} } , $msg ;
}

sub hasErrors {
    my $self = shift;
    return $self->{'errormsg'};
}

# ->setKw($kw);
sub setKw {
    my $self = shift;
    my $kw = shift // '';
    $self->{'Image'}->{'kw'} = $kw;
}
# $kw = ->getKw();
sub getKw {
    my $self = shift;
    return $self->{'Image'}->{'kw'};
}

# ->setKurz($kurz);
sub setKurz {
    my $self = shift;
    my $kurz = shift // '';
    $self->{'Image'}->{'kurz'} = $kurz;
}
# $kw = ->getKurz();
sub getKurz {
    my $self = shift;
    return $self->{'Image'}->{'kurz'};
}

# ->setScheme($scheme);
sub setScheme {
    my $self = shift;
    my $scheme = shift // '';
    $self->{'Image'}->{'scheme'} = $scheme;
}
# $kw = ->getScheme();
sub getScheme {
    my $self = shift;
    return $self->{'Image'}->{'scheme'};
}
# HeatMap->createImage ( 'kuerzel' => 'MUC'|'GER'|'NRW', 
#                        'kw' => 1-53 #Kalenderwoche,
#                        'scheme' => '', # scheme of image: '' Original Version jungest first; 0,0 upper left corner
#                      );
sub createImage {
    my $self = shift;
    my %args = @_;
    my $Config = $self->getConfig();

    my $kw = $args{'kw'};
    my $kurz = $args{'kuerzel'};

    # Bildausgabe Breit/Hoehe
    my $img_x = $Config->{'HeatMap'}{'img_x'} || 1200;
    # my $img_y = 1050;
    my $img_y = $Config->{'HeatMap'}{'img_y'} || 1150;

    # Farbe vom Bildhintergrund (der ist sonst beim gif weiss und beim jpg schwarz)
    # my $bgcolor = $Config->{'HeatMap'}{'bgcolor'};
    my $bgcolor = Imager::Color->new( $Config->{'HeatMap'}{'bgcolor'} );

    my $scheme = $Config->{'HeatMap'}{'scheme'} || 'orig';
    $scheme = $args{'scheme'} if ( $args{'scheme'} );

    my $img = Imager->new(
        xsize  => $img_x,        # Image width
        ysize  => $img_y,        # Image height
        channels => 4
    );
    $img->box(filled=>1, color=>$bgcolor );
    if ( $img->errstr ) {
        $self->setError('Fehler beim createImage: '.$img->errstr );
        return;
    }

    $self->{'Image'} = $img;

    $self->setKw( $kw ) if $kw;
    $self->setKurz( $kurz ) if $kurz;
    $self->setScheme( $scheme ) if $scheme;
 
}

# $HeatMap->exportImage ( 'filename' => $filename, 'format' => 'gif' )
sub exportImage {
    my $self = shift;
    my %args = @_;

    my $img = $self->{'Image'};
    my $fn = $args{'filename'} || '';
    my $format = $args{'format'} || 'sgi';
    my $file = 'platzhalter';
    # my $saved = 0;


    # for my $f ( qw( gif jpeg ) ) 
    # jpg is bigger than gif
    # foreach my $f ( qw "$format" ) {
    my $f = $format;

        # Check if given format is supported
        if ( $Imager::formats{$f} ) {
            
            $fn = $file.'.'.$f unless $fn;
            $fn = $fn.'.'.$f unless ( $fn =~ /\.$f\s*$/i );
            print "Storing image as: $fn\n";
 
            $img->write( file=>$fn );
            if ( $img->errstr ) {
                $self->setError('Fehler beim exportieren: '.$img->errstr );
                return;
            }
            # $saved = 1;

        }
    # }
    
}


# parseData ( 'files' => @files, 'kw' => $kw );
sub parseData
{
    my $self = shift;
    my %args = @_;
    my @infiles = @{ $args{'files'} };
    my $kw = $args{'kw'};
    $kw = $self->getKw() unless $kw;

    my @rki = ();
    # files der Reihe nach einlesen

    foreach my $infile (@infiles){
        open(IN ,"<:encoding(UTF-16)",$infile) || $self->setError( "open File $infile - error $!\n" );

        return if $self->hasErrors();
    
        my $cnt = 0;
        while(<IN>){
            my $line = $_;
            # $line =~ s/\"\"/"0,001"/g;
            $line =~ s/\"\"/"-10"/g;
            $line =~ s/\"//g;
            my @arr = split /\s+/, $line;
        
    # Debugging
    # print "rki:\n".Dumper (\@rki);
    # print "arr:\n".Dumper (\@arr);
    # print "cnt: $cnt \n";
    
            if ( $rki[$cnt] ) {
                my @rki_arr = @{$rki[$cnt]};
                my $c = 0;
                # mit folgejahrdaten ueberschreiben bis zur angeg. kw oder Datenende
                foreach my $f ( @arr ) {
    
    # print "cnt: $cnt - c: $c - kw: $kw\n";
                    last if ($c > $kw);
    
    # print "ersetze $rki_arr[$c] mit $f\n";
                    $rki_arr[$c] = $f;
                    $c++;
                }
    
                $rki[$cnt] = \@rki_arr;
            }
            else {
                push @rki, \@arr;
            }
            $cnt++;
    
    # print "ende rki: \n".Dumper (\@rki);
        }
    
        close IN;
    }
    
    # print Dumper( \@rki );
    
    # die obersten beiden Zeilen sind nur die Wochen und Prosa - verwenden wir nicht
    my $muell = shift @rki;
    # print "entsorge shift ".Dumper($muell);
    $muell = shift @rki;
    # print "entsorge shift ".Dumper($muell);
    
    $self->{'Image'}{'datamatrix'} = \@rki;
}

# \@ = ->getParsedData();
sub getParsedData
{
    my $self = shift;
    return $self->Image->{'datamatrix'};
}

# buildMainImage ( 'scheme' => <name> , 'kw' => $kw, 'kurz' => <ortskuerzel> );
sub buildMainImage {

    my $self = shift;
    my %args = @_;
    my $kw = $args{'kw'};
    $kw = $self->getKw() unless $kw;
    my $kurz = $args{'kurz'};
    $kurz = $self->getKurz() unless $kurz;
    my $scheme = $args{'scheme'};
    $scheme = $self->getScheme() unless $scheme;

    my $Config = $self->getConfig();
    my $copy = $Config->{'HeatMap'}{'copy'};

    my $kurze = $Config->{'HeatMapOrte'};
    my $ort = $kurze->{$kurz};

    $self->schemeFuncs( 'call' => 'scheme', 'kw' => $kw ) ; 
    $self->schemeFuncs( 'call' => 'buildFarblegende' );
    $self->schemeFuncs( 'call' => 'buildCopyright', 'text' => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter' );
    $self->schemeFuncs( 'call' => 'buildHeadline', 'headline' => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter' );

}

# #########################################
1;
