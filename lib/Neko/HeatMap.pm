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


sub hasErrors {
    my $self = shift;
    return $self->{'errormsg'};
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

    # Bildausgabe Breit/Hoehe
    my $img_x = $Config->{'HeatMap'}{'img_x'} // 1200;
    # my $img_y = 1050;
    my $img_y = $Config->{'HeatMap'}{'img_y'} // 1150;

    my $kurze = $Config->{'HeatMapOrte'};
    my $ort = $kurze->{$kurz};

    # Farbe vom Bildhintergrund (der ist sonst beim gif weiss und beim jpg schwarz)
    # my $bgcolor = $Config->{'HeatMap'}{'bgcolor'};
    my $bgcolor = Imager::Color->new( $Config->{'HeatMap'}{'bgcolor'} );

    my $scheme = Imager::Color->new( $Config->{'HeatMap'}{'scheme'} ) // 'orig';

    my @infiles = @ { $args{'infiles'} };

    my $img = Imager->new(
        xsize  => $img_x,        # Image width
        ysize  => $img_y,        # Image height
        channels => 4
    );
    $img->box(filled=>1, color=>$bgcolor );

    $self->{'Image'} = $img;

    $self->parseData ( 'files' => @infiles ); # stored in \@ $self->Image->datamatrix
    $self->buildMainImage ( 'scheme' => $scheme , 'kw' => $kw ); # stored in \@ $self->Image->datamatrix
    
 
# Noch die Ueberschrift drueber
$img->string(x => ( ( $feldSizex*2)+$offsetx) , y => 40,
             font => $font,
             string => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter',
             color => 'black',
             size => $feldSizex*2,
             aa => 3);
 
}

# $HeatMap->exportImage ( 'image' => Imager::new , 'filename' => $filename, 'format' => 'gif' )
sub exportImage {
    my $self = shift;
    my %args = @_;
    my $img = $args{'image'};
    my $fn = $args{'filename'};
    my $format = $args{'format'} // 'sgi';
    my $file = 'platzhalter';
    my $saved = 0;

    # for my $f ( qw( gif jpeg ) ) 
    # jpg is bigger than gif
    for my $f ( qw( $format ) ) {

        # Check if given format is supported
        if ($Imager::formats{$f}) {
            # my $fn = $file."_".   sprintf("%02d", $kw).".".$f;
            $fn = $file.'.'.$f unless $fn;
            print "Storing image as: $fn\n";
 
            $img->write(file=>$fn) or
# XXXXX hier Fehlerbehandlung statt die!
                die $img->errstr;
            $saved = 1;

        }
    }
    
}



# parseData ( 'files' => @files );
sub parseData
{
    my $self = shift;
    my %args = @_;
    my @infiles = @{ $args{'files'} };

# rki-Daten parsen - auslagern
    my @rki = ();
    # files der Reihe nach einlesen

    foreach my $infile (@infiles){
        open(IN ,"<:encoding(UTF-16)",$infile) || die "open File $infile - error $!\n";
    
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

# buildMainImage ( 'scheme' => <name> , 'kw' => $kw );
sub buildMainImage {

    my $self = shift;
    my %args = @_;
    my $kw = $args{'kw'};
    my $scheme = $args{'scheme'};

    # split here for special patterns

    if ( lc ( $scheme ) eq '' ){
        $self->ORIG_scheme( 'kw' => $kw ) ; 
        $self->buildOrigFarblegende ();
        $self->buildOrigCopyright ();
    }
    # elsif ( lc ( $scheme ) eq 'xxx' ){}
    else { $self->ORIG_scheme( 'kw' => $kw ) ; }

}


# eventuell in ein eigenes pm auslagern, was dann nachgeladen wird und gleichnamige subs hat
sub ORIG_scheme( 'kw' => $kw )
{
    my $self = shift;
    my %args = @_;
    # my $scheme = $args{'scheme'};
    my $kw = $args{'kw'};

    my $Config = $self->getConfig();

    my $img = $self->{'Image'};
    my @matrix = @{ $self->{'Image'}{'datamatrix'} };

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $feldSizey = $Config->{'HeatMap'}{'feldSize_y'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};
    my $offsety $Config->{'HeatMap'}{'offset_y'};
    my $colors # $color = @{$colors->{$weight}};
    my $KW_fontSize = $feldSizex;

    # ttf-Font von System verwenden 
    my $font_file = $Config->{'HeatMap'}{'font_file'};
# XXXX das die noch abfangen
    my $font = Imager::Font->new(file => $font_file ) or die;

    my @point_datas = ();

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
        if ( $t == $kw-1 ){ print "$ag: $feld\n"; }

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

    

}

sub buildOrigFarblegende
{
    my $self = shift;
    my %args = @_;

    my $Config = $self->getConfig();

    my $kurze = $Config->{'HeatMapOrte'};
    my $ort = $kurze->{$kurz};

    # XXXXX HIER Config auslutschen

    # Farb-Legende unten

$i = '';
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

sub buildOrigCopyright
{
    my $self = shift;
    my %args = @_;

    my $Config = $self->getConfig();

    my $kurze = $Config->{'HeatMapOrte'};
    my $ort = $kurze->{$kurz};


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
             string => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter',
             color => 'black',
             size => $feldSizex*2,
             aa => 3);



}

sub buildOrigHeadline
{
    my $self = shift;
    my %args = @_;
    my $Config = $self->getConfig();

    my $kurze = $Config->{'HeatMapOrte'};
    my $ort = $kurze->{$kurz};


    my $img = $self->{'Image'};

    my $feldSizex = $Config->{'HeatMap'}{'feldSize_x'};
    my $offsetx = $Config->{'HeatMap'}{'offset_x'};

    # ttf-Font von System verwenden 
    my $font_file = $Config->{'HeatMap'}{'font_file'};
# XXXX das die noch abfangen
    my $font = Imager::Font->new(file => $font_file ) or die;

    # Noch die Ueberschrift drueber
    $img->string(x => ( ( $feldSizex*2)+$offsetx) , y => 40,
             font => $font,
             string => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter',
             color => 'black',
             size => $feldSizex*2,
             aa => 3);


}


sub xxx
{

# Kommandozeilenparameter:
my $kurz = shift // 'MUC';
my $kw = shift // 52;
my $use_this_filename = shift // '';
my @infiles = @ARGV;

# -h - Hilfe der Ordnung halber hingefaked
if ( $kurz eq '-h' ) {
    &usage_and_die();
}

# Config-Daten-Variablen

# Kuerzel - Langbezeichnung Zuordnung - wird im Bild oben verwendet
my $kurze = {
    'NRW' => 'BL NRW',
    'MUC' => 'SK München',
    'GER' => 'GERMANY'
    };
my $ort = $kurze->{$kurz};


# Bildausgabe Breit/Hoehe
my $img_x =  1200;
# my $img_y = 1050;
my $img_y = 1150;

# Abstand von links und von oben zum Bildrand
my $offsetx = 50;
my $offsety = 40;

# Farbe vom Bildhintergrund (der ist sonst beim gif weiss und beim jpg schwarz)
my $bgcolor = Imager::Color->new( 255, 255, 255 );

# einzelne Kasterl pro HeaatFarbe SizeX=Breite SizeY=Hoehe,
my $feldSizex = 20;
my $feldSizey = 40;
my $KW_fontSize = $feldSizex;

# ttf-Font von System verwenden 
my $font = Imager::Font->new(file => '/System/Library/Fonts/Supplemental/Times New Roman.ttf') or die;

# Fontgroesse fuer den Copyright-Text unten rechts
my $copyFont = $feldSizex;

# Farbschema
my $colors = {
-10 => [ 255, 255, 255 ], # keine Angabe
 0 => [ 210, 255, 210 ],
10 => [ 175, 255, 175 ],
20 => [ 0, 255, 0 ], #grün
30 => [ 175, 255, 0 ], #gelb
40 => [ 255, 255, 0 ],
50 => [ 255, 225, 0 ], #gelb
60 => [ 255, 200, 0 ], #orange
70 => [ 255, 175, 0 ],
80 => [ 255, 150, 0 ],
90 => [ 255, 100, 0 ],
100 => [ 255, 75, 0 ], 
150 => [ 255, 50, 0 ], #rot
200 => [ 255, 25, 0 ],
250 => [ 255, 0, 0 ],
300 => [ 225, 0, 0 ],
350 => [ 200, 0, 0 ],
400 => [ 175, 0, 0 ],
450 => [ 150, 0, 0 ], #dunkelrot
500 => [ 150, 0, 25 ],
550 => [ 150, 0, 50 ],
600 => [ 125, 0, 75 ], 
650 => [ 100, 0, 100 ],
700 => [ 100, 0, 150 ], 
750 => [ 125, 0, 200 ],  # lila
800 => [ 150, 0, 225 ],
850 => [ 150, 0, 255 ],
900 => [ 175, 0, 255 ],
950 => [ 200, 0, 255 ],
1000 => [ 255, 0, 255 ], #pink
1100 => [ 255, 0, 255 ], 
1200 => [ 125, 225, 255 ],
1300 => [ 100, 200, 200 ],
1400 => [ 50, 150, 200 ],
1500 => [ 50, 100, 255 ],
1600 => [ 0, 100, 255 ],
1700 => [ 0, 0, 225 ],
1800 => [ 0, 0, 200 ], #schwarz
1900 => [ 0, 0, 150 ],
2000 => [ 0, 0, 150 ],
2100 => [ 0, 0, 100 ],
2200 => [ 0, 0, 0 ],
2300 => [ 0, 0, 0 ],
2400 => [ 0, 0, 0 ],
2500 => [ 0, 0, 0 ],
2600 => [ 0, 0, 0 ],
2700 => [ 0, 0, 0 ],
2800 => [ 0, 0, 0 ],
2900 => [ 0, 0, 0 ],
3000 => [ 0, 0, 0 ],
3100 => [ 0, 0, 0 ],
3200 => [ 0, 0, 0 ],
3300 => [ 0, 0, 0 ],
3400 => [ 0, 0, 0 ],
3500 => [ 0, 0, 0 ],
3600 => [ 0, 0, 0 ],
3700 => [ 0, 0, 0 ],
3800 => [ 0, 0, 0 ],
3900 => [ 0, 0, 0 ],
4000 => [ 0, 0, 0 ],
4100 => [ 0, 0, 0 ],
4200 => [ 0, 0, 0 ],
4300 => [ 0, 0, 0 ],
4400 => [ 0, 0, 0 ],
4500 => [ 0, 0, 0 ],
4600 => [ 0, 0, 0 ],
4700 => [ 0, 0, 0 ],
4800 => [ 0, 0, 0 ],
4900 => [ 0, 0, 0 ],
5000 => [ 0, 0, 0 ],
5100 => [ 0, 0, 0 ],
5200 => [ 0, 0, 0 ],
5300 => [ 0, 0, 0 ],
5400 => [ 0, 0, 0 ],
5500 => [ 0, 0, 0 ],
5600 => [ 0, 0, 0 ],
5700 => [ 0, 0, 0 ],
5800 => [ 0, 0, 0 ],
5900 => [ 0, 0, 0 ],
6000 => [ 0, 0, 0 ],
6100 => [ 0, 0, 0 ],
6200 => [ 0, 0, 0 ],
};

my @border_color = [ 0, 0, 0 ];

my @rki = ();

# Datum und Output, Copyright (unten rechts im Bild)
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
my $dat = sprintf("%04d-%02d-%02d", ($year+1900), ($mon +1), $mday );
my $copy = $dat.' RKI https://survstat.rki.de/ visualized by @muc_NEKO';

print "\n";

# files der Reihe nach einlesen

foreach my $infile (@infiles){
    open(IN ,"<:encoding(UTF-16)",$infile) || die "open File $infile - error $!\n";

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

# Heatmap auf die hart Tour bauen


my $img = Imager->new(
    xsize  => $img_x,        # Image width
    ysize  => $img_y,        # Image height
    channels => 4
);
$img->box(filled=>1, color=>$bgcolor );

my $file = $use_this_filename;
my $format;

my @matrix = @rki;

my @point_datas = ();

# print Dumper(\@point_datas);

my $counter = 0;
# print Dumper(\@matrix);

foreach my $p ( @matrix ) {

    $counter++;

# print "p: ".Dumper($p) ."\n";


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
        if ( $t == $kw-1 ){ print "$ag: $feld\n"; }

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

#Labeln obere Reihe mit der KW-Angabe

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
# bis hier ausgelagert

# Farb-Legende unten

$i = '';
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


#copyrighten
# bottom right-hand corner of the image
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
             string => 'HeatMap Covid19, Inzidenzen, '.$ort.', nach Alter',
             color => 'black',
             size => $feldSizex*2,
             aa => 3);
 
# speichern

# OutputFilename generieren
if ( $use_this_filename ) {
    $file = $use_this_filename;
}
else {
    # Output Filename generieren 03:00 einfach hart anhängen, das paßt meist schon, Sonderloecken via use_filename machen
    $file = 'HeatMap_'.$kurz.'_'.(sprintf("%04d_%02d_%02d", ($year+1900), ($mon +1), $mday ));
}

# sgi ging auf Mac von Haus aus, alles andere brauchte etwas Liebe (=libs)
$format = 'sgi';
my $saved = 0;

# for my $f ( qw( gif jpeg ) ) {
for my $f ( qw( gif ) ) {

    # Check if given format is supported
    if ($Imager::formats{$f}) {
        my $fn = $file."_".   sprintf("%02d", $kw).".".$f;
        print "Storing image as: $fn\n";
 
        $img->write(file=>$fn) or
            die $img->errstr;
        $saved = 1;

    }
}

# Fallback
if ( !$saved ) {
    print "Storing image as: $file\n";
 
    $img->write(file=>$file) or
            die $img->errstr;
}

}

# #########################################
1;
