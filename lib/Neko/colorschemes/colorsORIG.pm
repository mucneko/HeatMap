#!/usr/bin/perl

package Neko::colorschemes::colorsORIG;

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
               ORIG_buildHeadline
               ORIG_buildCopyright
               ORIG_buildFarblegende
               ORIG_scheme
            );
               # ORIG_calculateColor internal use

my $d = 0; #Debuginf 0|1

# ORIG_buildCopyright( 'text' => <copyrightText> );
sub ORIG_buildCopyright 
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

# calculate color for ORIG scheme
sub ORIG_calculateColor
{
    # calculate color for ORIG scheme
    my %args = @_;

    my $colors = $args{'colors'};
    my $feld = $args{'feld'};
    my $weight = $args{'weight'};

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
# errorhandling! if feld an weight are missing

# print "$weight\n";
# print "$colors->{$weight}  -> @{$colors->{$weight}}\n";
    return @{$colors->{$weight}};

}

# buildOrigHeadline ( 'headline' => <headline> );)
sub ORIG_buildHeadline
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
sub ORIG_buildFarblegende
{
    my $self = shift;
    my %args = @_;

    my $Config = $self->getConfig();

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $feldSizey = $Config->{'HeatMap'}{'feldSize_y'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};
    my $offsety = $Config->{'HeatMap'}{'offset_y'};
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
    # my $x = $feldSizex + $offsetx;
    my $x = $feldSizex;


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

        # Kasterl drum - platt brutal gewachsen ohne Intelligenz
        if ( $l > 4200 ) {
            my @mborder_color = $colors->{ ($l -4200) } ;

            foreach my $i ( 9..10 ) {
                $img->box( color=> @mborder_color,
                      xmin=> $x +$i, ymin=> $y -$feldSizey +$i,
                      xmax=> $x+$feldSizex -$i, ymax=> $y -$i,
                      filled => 0 ,
                      aa => 4);
                if ( $img->errstr ) {
                    $self->setError('Fehler beim 1 boxen: '.$img->errstr );
                }
            }
        }
        if ( $l > 2200 ) {
            my @mborder_color = $colors->{ ($l -2200) } ;

            foreach my $i ( 5..7 ) {
                $img->box( color=> @mborder_color,
                      xmin=> $x +$i, ymin=> $y -$feldSizey +$i,
                      xmax=> $x+$feldSizex -$i, ymax=> $y -$i,
                      filled => 0 ,
                      aa => 4);
                if ( $img->errstr ) {
                    $self->setError('Fehler beim 2 boxen: '.$img->errstr );
                }
            }
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

# ORIG_scheme( 'kw' => $kw )
sub ORIG_scheme
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
    my $colors = $self->getColorMap();
    my $KW_fontSize = $feldSizex;

    my @verwendeteWerte = ();

    # ttf-Font von System verwenden
    my $font_file = $Config->{'HeatMap'}{'font_file'};
    my $font = Imager::Font->new( file => $font_file ) or $self->setError( "Fehler beim Font laden im ORIG_scheme: $!" );

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
        my $y2 = $y + $feldSizey;
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

            my @color = ORIG_calculateColor (
                                        'feld' => "$feld",
                                      'colors' => $colors,
                                   );

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
    
            # Kasterl drum - platt brutal gewachsen ohne Intelligenz
            if ( $weight > 4200 ) {
                # my @mborder_color = $colors->{$weight -4200};
                my @mborder_color = ORIG_calculateColor( 
                                           'weight' => $weight -4200,
                                           'colors' => $colors,
                                           );

                foreach my $i ( 9..10 ) {
                    $img->box( color => \@mborder_color,
                         xmin=> $x +$i, ymin=> $y +$i,
                         xmax=>$x2 -$i, ymax=>$y2 -$i,
                         filled => 0,
                         aa => 4);
                    if ( $img->errstr ) {
                        $self->setError('Fehler beim 4 boxen: '.$img->errstr );
                    }
                }
            }
            elsif ( $weight > 2200 ) {
            # my @mborder_color = $colors->{$weight -2200};
                my @mborder_color = ORIG_calculateColor(
                                           'weight' => $weight -2200,
                                           'colors' => $colors,
                                           );


                foreach my $i ( 5..7 ) {
                    $img->box( color => \@mborder_color,
                         xmin=> $x +$i, ymin=> $y +$i,
                         xmax=>$x2 -$i, ymax=>$y2 -$i,
                         filled => 0,
                         aa => 4);
                    if ( $img->errstr ) {
                        $self->setError('Fehler beim 5 boxen: '.$img->errstr );
                    }
                }
            }
            $img->box( color=> @border_color, xmin=> $x, ymin=> $y,
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
