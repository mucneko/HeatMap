#!/usr/bin/perl

package Neko::colorschemes::schemeEASY;

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
               EASY_buildHeadline
               EASY_buildCopyright
               EASY_buildFarblegende
               EASY_scheme
            );
               # EASY_calculateColor internal use

my $d = 0; #Debuginf 0|1

# EASY_buildCopyright( 'text' => <copyrightText> );
sub EASY_buildCopyright 
{

    my $self = shift;
    my %args = @_;

    my $Config = $self->getConfig();
    my $img = $self->{'Image'};

    my $copyDetails = $args{'text'} || '';

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};
    my $copy = $Config->{'HeatMap'}{'copy'};
    my $copyFont = $feldSizex;

    # ttf-Font von System verwenden
    my $font_file = $Config->{'HeatMap'}{'font_file'};
    my $font = Imager::Font->new( file => $font_file ) or $self->setError( "Fehler beim Font laden im buildOrigCopyright: $!" );

    return if $self->hasErrors();

    # Datum und Output, Copyright (unten rechts im Bild)
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    my $dat = sprintf("%04d-%02d-%02d", ($year+1900), ($mon +1), $mday );
    $copy = $dat.' '.$copy;


    # Copyright drunterkleben
    # bottom right-hand corner of the image
    $img = $self->{'Image'};
    $img->align_string(x => $img->getwidth() - 1,
                   y => $img->getheight() - 1,
                   halign => 'right',
                   valign => 'bottom',
                   string => $copy,
                     font => $font,
                    color => 'black',
                     size => $copyFont,
                       aa => 1);
    if ( $img->errstr ) {
        $self->setError('Fehler beim 1 align_string: '.$img->errstr );
    }

    # Noch die Ueberschrift drueber
    $img->string(x => ( ( $feldSizex*2)+$offsetx) , y => 40,
             font => $font,
             string => $copyDetails,
             color => 'black',
             size => $feldSizex*2,
             aa => 3);
    if ( $img->errstr ) {
        $self->setError('Fehler beim 1 string: '.$img->errstr );
    }

}

# calculate color for EASY scheme
sub EASY_calculateColor
{
    # calculate color for EASY scheme
    my %args = @_;

    my $colors = $args{'colors'};
    my $feld = $args{'feld'};
    my $weight = $args{'weight'};

    my @keys = sort {$a<=>$b} ( keys %{$colors}  ); 
    my $lastkey = $keys[-1];

    if ( !$feld && !$weight ) { $feld = 0; }

    if ( defined $feld ) {
        $weight = -10;

        $weight = nearest(10, $feld );
        if ( $feld >= 100 ) {
            $weight = nearest(50, $feld );
        }
        if ( $feld >= 1000 ) {
            $weight = nearest(100, $feld );
        }
    }

    # somewhere has to be an end
    if ( $weight > $lastkey ) { $weight = $lastkey; }

    # errorhandling! if feld and weight are missing

    # should not happen, except of the colormap is broken
    my $error = '';
    if ( !defined $weight ){
        $error .= "weight ist nicht definiert\n";
    }
    if ( !defined $colors ){
        $error .= "colors ist nicht definiert\n";
    }
    if ( !defined $colors->{$weight} ){
        $error .= "colors->{$weight} ist nicht definiert\n";
    }

    print 'ERROR: '.$error.Dumper(\%args) if $error;
    
# print "$weight, $lastkey\n";
#  print "\$colors->{$weight}  -> @{$colors->{$weight}}\n";
    return @{$colors->{$weight}};

}

# buildOrigHeadline ( 'headline' => <headline> );)
sub EASY_buildHeadline
{
    my $self = shift;
    my %args = @_;
    my $Config = $self->getConfig();

    my $headline = $args{'headline'};

    my $img = $self->{'Image'};

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};

    # ttf-Font von System verwenden
    my $font_file = $Config->{'HeatMap'}{'font_file'};
    my $font = Imager::Font->new( file => $font_file ) or $self->setError( "Fehler beim Font laden im buildOrigHeadline: $!" );

    return if $self->hasErrors();

    # Noch die Ueberschrift drueber
    $img->string(x => ( ( $feldSizex*2)+$offsetx) , y => 40,
             font => $font,
             string => $headline,
             color => 'black',
             size => $feldSizex*2,
             aa => 3);
    if ( $img->errstr ) {
        $self->setError('Fehler beim 2 string: '.$img->errstr );
    }
}

# color legend at bottom
sub EASY_buildFarblegende
{
    my $self = shift;
    my %args = @_;

    my $Config = $self->getConfig();

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $feldSizey = $Config->{'HeatMap'}{'feldSize_y'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};
    my $offsety = $Config->{'HeatMap'}{'offset_y'};
    my $reversey = $Config->{'HeatMap'}{'reverse_y'} || 0;
    my $colors = $self->getColorMap(); # $color = @{$colors->{$weight}};

    # ttf-Font von System verwenden
    my $font_file = $Config->{'HeatMap'}{'font_file'};
    my $font = Imager::Font->new( file => $font_file ) or $self->setError( "Fehler beim Font laden im buildOrigFarblegende: $!" );

    return if $self->hasErrors();

    my $img = $self->{'Image'};

    my @border_color = [ 0, 0, 0 ];

    my $i = '';
    my $c = 0;
    my $y = 20*$feldSizey + $offsety;
    my $x = $feldSizex + $offsetx;


    foreach my $l ( sort { $a <=> $b } ( keys %{$colors} ) ){

        next if ( $l < 0 );

        # $c++;

        my $von = $l;
       $von = $l - 5 if( $l>4);
        my $bis = ($l*1 +4);
        if ( $l >= 100 ) {
            $von = $l - 25;
            $bis = $l*1 +24;
        }
        if ( $l >= 1000 ) {
            $von = $l - 50;
            $bis = $l +49;
        }

        $i = "$von - $bis";
        if ( $c +1 >= ( scalar ( keys %{$colors} ) -1 ) ) {   $i = " > $von"; }
        $img->string(x => $x+$feldSizex+5 , y => $y -5,
             font => $font,
             string =>  $i,
             color => 'black',
             size => $feldSizex*0.75,
             aa => 1);
        if ( $img->errstr ) {
            $self->setError('Fehler beim 3 string: '.$img->errstr );
        }

        my $fill = Imager::Fill->new(solid => $colors->{$l}, combine => 'normal');

        $img->box( xmin=> $x, ymin=> $y -$feldSizey ,
               xmax=> $x+$feldSizex, ymax=> $y ,
               fill=> $fill
        );
        if ( $img->errstr ) {
            $self->setError('Fehler beim 1 box: '.$img->errstr );
        }

        $img->box( color=> @border_color,
                  xmin=> $x, ymin=> $y -$feldSizey,
                  xmax=> $x+$feldSizex, ymax=> $y,
                  filled => 0 ,
                  aa => 4);
        if ( $img->errstr ) {
            $self->setError('Fehler beim 3 boxen: '.$img->errstr );
        }
        $c++;
    # print "c: $c\n";
        # if ( ( $c % 5 ) == 0 ) {
        # $x += nlowmult ( 1, ($c / 5) )  + ( $feldSizex*5 );
        # $y = 19*$feldSizey + 2*$offsety;
    # }
        if ( ( $c % 8 ) == 0 ) {
            # $x += nlowmult ( 1, ($c / 8) )  + ( $feldSizex*8 );
            $x += nlowmult ( 1, ($c / 8) )  + ( $feldSizex*5 );
            $y = 19*$feldSizey + 2*$offsety;
        }

        else {
            $y = $y+$feldSizey;
        }
    }

}

# EASY_scheme( 'kw' => $kw )
sub EASY_scheme
{
    my $self = shift;
    my %args = @_;
    # my $scheme = $args{'scheme'};
    my $kw = $args{'kw'};

    my $Config = $self->getConfig();

    my $img = $self->{'Image'};
    my @matrix = @{ $self->{'Image'}{'datamatrix'} };

    my @rki = @{ $self->{'Image'}{'datamatrix'} };

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $feldSizey = $Config->{'HeatMap'}{'feldSize_y'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};
    my $offsety = $Config->{'HeatMap'}{'offset_y'};
    my $reversey = $Config->{'HeatMap'}{'reverse_y'} || 0;
    my $img_x = $Config->{'HeatMap'}{'img_x'};
    my $img_y = $Config->{'HeatMap'}{'img_y'};
    my $colors = $self->getColorMap();
    my $KW_fontSize = $feldSizex;
    my $bottom_abstand = ( 8 * $feldSizey ) + nearest ( 1, ( 0.5 * $feldSizey ) );

    my @verwendeteWerte = ();

    # ttf-Font von System verwenden
    my $font_file = $Config->{'HeatMap'}{'font_file'};
    my $font = Imager::Font->new( file => $font_file ) or $self->setError( "Fehler beim Font laden im EASY_scheme: $!" );

    return if $self->hasErrors();

    my @point_datas = ();
    my @border_color = [ 0, 0, 0 ];

# print Dumper(\@point_datas);

    my $counter = 0;
# print Dumper(\@matrix);

    foreach my $p ( @matrix ) {
        $counter++;

        my $reihe = $counter;
        my $y = $reihe * $feldSizey + $offsety;
        if ( $reversey ) { $y = ( $img_y - ($reihe * $feldSizey + $offsety ) ) - $bottom_abstand; }
        my $y2 = ( $y + $feldSizey );
        my $x2 = 0;

        my $fc = 0; # Feldcounter

        # Altersgruppe mal abfangen und aufheben
        my $ag = shift @{$p};
        $ag =~ s/^A//g;

        # letzte Zeile hat das manchmal
        next if ( uc($ag) eq 'UNBEKANNT' );

        foreach my $t ( ($kw) .. ( scalar( @{$p} ) -1 ), 0 .. $kw-1 ) {
            my @line = @{$p};

# if ( $t > 49 ){
# print '@line: '."@line\n";
# print 'scalar: ' .scalar( @line )."\n";
# }

            my $feld = $line[$t];

# print '$feld: '.$feld."\n";
# print '$t: '.$t."\n";

            # Ausgabe auf der Shell letzte Spalte
            if ( $t == $kw-1 ){
                # print "$ag: $feld\n";
                push @verwendeteWerte, "$ag: $feld";
            }
    
            $fc++;
            # last if ( $fc > $kw );
    
            # bei den Inzidenzen putzen, die kommen als 1.234,56
            $feld =~ s/\.//g;
            $feld =~ s/\,/\./g;

            my @color = EASY_calculateColor (
                                        'feld' => "$feld",
                                      'colors' => $colors,
                                   );

            # my $x = $img_x - ($fc * $feldSizex + $offsetx );
            my $x = $fc * $feldSizex + $offsetx;
            $x2 = $x + $feldSizex;

# print "Zeichne: $x, $y -> $x2, $y2 color: @color\n";

            my $fill = Imager::Fill->new(solid => \@color, combine => 'normal');
            $img->box( xmin=> $x, ymin=> $y,
                       xmax=> $x2, ymax=> $y2,
                       fill=> $fill
                     );
            if ( $img->errstr ) {
                $self->setError('Fehler beim 2 box: '.$img->errstr );
            }

            # I need weight here as well.
            my $weight = -10;
            $weight = nearest(10, $feld );
            if ( $feld >= 100 ) {
                $weight = nearest(50, $feld );
            }
            if ( $feld >= 1000 ) {
                $weight = nearest(100, $feld );
            }
    
            $img->box( color => @border_color, xmin=> $x, ymin=> $y,
                         xmax=>$x2, ymax=>$y2, filled => 0);
            if ( $img->errstr ) {
                $self->setError('Fehler beim 6 boxen: '.$img->errstr );
            }
        }

        # Altersangabe hinten hin schreiben
        $img->string(x => ($x2 + 4), y => $y2,
             font => $font,
             string =>  $ag,
             color => 'black',
             size => $KW_fontSize,
             aa => 1);
        if ( $img->errstr ) {
            $self->setError('Fehler beim 4 string: '.$img->errstr );
        }

    }

    # KW
    $img->string( x => ($offsetx -( $feldSizex ) ), y => ( $offsety + ( $feldSizey -5 ) ),
                 font => $font,
                 string =>  'KW',
                 color => 'black',
                 size => $KW_fontSize,
                 aa => 1);
    if ( $img->errstr ) {
        $self->setError('Fehler beim 5 string: '.$img->errstr );
    }

    # 1..53
    my $i = 0;
    foreach my $l ( $kw+1 .. ( scalar( @{$rki[3]} ) ), 1 .. $kw ){
        $i++;
        my $x = $i * $feldSizex + $offsetx;
        $img->string(x => $x, y => ( $offsety + ( $feldSizey -5 ) ),
                 font => $font,
                 string =>  $l,
                 color => 'black',
                 size => $KW_fontSize,
                 aa => 1);
        if ( $img->errstr ) {
            $self->setError('Fehler beim 6 string: '.$img->errstr );
        }
    }

    $self->{'parsedData'}{'lastkw'} = \@verwendeteWerte;

}



# ##############################################
1;
