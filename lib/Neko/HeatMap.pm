#!/usr/bin/perl


#OO-Modul
package Neko::HeatMap;

use strict;
use warnings;

# nonOO-Helper
use Neko::hmFunctions;

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
        push @{$self->{'errormsg'}}, "HeatMap::setColorMap unbekannter Parameter. Erwartet: 'map' oder 'file'";
    }
}


sub setError {
    my $self = shift;
    my $msg = shift;
    push @{ $self->{'errormsg'};
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
#                        'infiles' => \@infiles,
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

    my $scheme = Imager::Color->new( $Config->{'HeatMap'}{'scheme'} ) || 'orig';

    my $infiles = $args{'infiles'};

    my $img = Imager->new(
        xsize  => $img_x,        # Image width
        ysize  => $img_y,        # Image height
        channels => 4
    );
    $img->box(filled=>1, color=>$bgcolor );

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
            $fn = $fn.".".$f unless ( $fn !~ /\.$f$/i );
            $fn = $file.'.'.$f unless $fn;
            print "Storing image as: $fn\n";
 
            $img->write(file=>$fn);
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

    # split here for special patterns

    if ( lc ( $scheme ) eq 'orig' ){
        $self->ORIG_scheme( 'kw' => $kw ) ; 
        $self->buildOrigFarblegende ();
        $self->buildOrigCopyright ( 'text' => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter' );
        $self->buildOrigHeadline( 'headline' => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter' );
    }
    # elsif ( lc ( $scheme ) eq 'xxx' ){}
    # noch ist es doppelt
    else { 
        $self->ORIG_scheme( 'kw' => $kw ) ; 
        $self->buildOrigFarblegende ();
        $self->buildOrigCopyright ( 'text' => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter' );
        $self->buildOrigHeadline( 'headline' => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter' );
    }

}


# eventuell in ein eigenes pm auslagern, was dann nachgeladen wird und gleichnamige subs hat
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
# XXXX das die noch abfangen
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

        my $weight = -10;
        # die mit dem -1 nicht durchs berechnen schicken.
        # if ( $feld ne '-1' ) {
            # bei den Inzidenzen putzen, die kommen als 1.234,56
            $feld =~ s/\.//g;
            $feld =~ s/\,/\./g;

# print "Farbe: $feld -> ";
            $weight = nearest(10, $feld );
            if ( $feld >= 100 ) {
                $weight = nearest(50, $feld );
            }
            if ( $feld >= 1000 ) {
                $weight = nearest(100, $feld );
            }
        # }
# print "$weight\n";

# print "Verwende Farbe $weight aus $feld\n";

        my @color = @{$colors->{$weight}};

        my $x = $fc * $feldSizex + $offsetx;
        $x2 = $x + $feldSizex;

# print "Zeichne: $x, $y -> $x2, $y2 color: @color\n";

        my $fill = Imager::Fill->new(solid => \@color, combine => 'normal');
        $img->box( xmin=> $x, ymin=> $y,
                   xmax=> $x2, ymax=> $y2,
                   fill=> $fill
                 );

        # Kasterl drum - platt brutal gewachsen ohne Intelligenz
        if ( $weight > 4200 ) {
            my @mborder_color = $colors->{$weight -4200};

            foreach my $i ( 9..10 ) {
                $img->box( color => @mborder_color,
                         xmin=> $x +$i, ymin=> $y +$i,
                         xmax=>$x2 -$i, ymax=>$y2 -$i,
                         filled => 0,
                         aa => 4);
            }
        }
        elsif ( $weight > 2200 ) {
            my @mborder_color = $colors->{$weight -2200};

            foreach my $i ( 5..7 ) {
                $img->box( color => @mborder_color,
                         xmin=> $x +$i, ymin=> $y +$i,
                         xmax=>$x2 -$i, ymax=>$y2 -$i,
                         filled => 0,
                         aa => 4);
            }
        }
        $img->box( color=> @border_color, xmin=> $x, ymin=> $y,
                         xmax=>$x2, ymax=>$y2, filled => 0);
    }

    # Altersangabe hinten hin schreiben
    $img->string(x => ($x2 + 4), y => $y2,
             font => $font,
             string =>  $ag,
             color => 'black',
             size => $KW_fontSize,
             aa => 1);

    }
 

    # KW
    $img->string( x => ($offsetx -( $feldSizex ) ), y => ( $offsety + ( $feldSizey -5 ) ),
                 font => $font,
                 string =>  'KW',
                 color => 'black',
                 size => $KW_fontSize,
                 aa => 1);

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
    }

    $self->{'parsedData'}{'lastkw'} = \@verwendeteWerte;


    
}

# Farb-Legende unten
sub buildOrigFarblegende
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
# XXXX das die noch abfangen
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

        my $fill = Imager::Fill->new(solid => $colors->{$l}, combine => 'normal');

        $img->box( xmin=> $x, ymin=> $y -$feldSizey ,
               xmax=> $x+$feldSizex, ymax=> $y ,
               fill=> $fill
        );

        # Kasterl drum - platt brutal gewachsen ohne Intelligenz
        if ( $l > 4200 ) {
            my @mborder_color = $colors->{ ($l -4200) } ;

            foreach my $i ( 9..10 ) {
                $img->box( color=> @mborder_color,
                      xmin=> $x +$i, ymin=> $y -$feldSizey +$i,
                      xmax=> $x+$feldSizex -$i, ymax=> $y -$i,
                      filled => 0 ,
                      aa => 4);
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
            }
        }

        $img->box( color=> @border_color,
                  xmin=> $x, ymin=> $y -$feldSizey,
                  xmax=> $x+$feldSizex, ymax=> $y,
                  filled => 0 ,
                  aa => 4);

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

# buildOrigCopyright( 'text' => <copyrightText> );
sub buildOrigCopyright
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

    # Noch die Ueberschrift drueber
    $img->string(x => ( ( $feldSizex*2)+$offsetx) , y => 40,
             font => $font,
             string => $copyDetails,
             color => 'black',
             size => $feldSizex*2,
             aa => 3);



}

# buildOrigHeadline ( 'headline' => <headline> );)
sub buildOrigHeadline
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
}


# #########################################
1;
