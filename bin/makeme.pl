#!/usr/bin/perl

package functions;
use strict;
use warnings;


use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

use Encode 'encode';                    # UTF8<->8859-1 forcieren


# Template Toolkit
use Template;

our (@ISA, @EXPORT);

@ISA = qw(Exporter);

@EXPORT = qw(
              xxxx
            );

sub xxxx
{
}


my $datum = shift @ARGV // die "kein Datum mitgegeben (z.B. 2022_04_03_0600)";
my $kw = shift @ARGV // 16;
my $tar = '/usr/bin/tar';

my $MUC_2021 = 'survstat_MUC_2021_2022_07_13';
my $GER_2021 = 'survstat_GER_2021_2022_07_13';

my $MUC = "survstat_MUC_$datum";
my $GER = "survstat_GER_$datum";

chdir '../'; 
print `pwd`;

foreach my $dest ( $MUC, $GER ){
    if ( !-f "$dest/Data.csv" ){
        `mkdir $dest`;
        `cp $dest.zip $dest`;
        chdir $dest;
        print `$tar vxfz $dest.zip` ."\n";
        `rm $dest.zip`;
        chdir '..';
    }
}

chdir 'bin/';

# print `pwd`;

my $call1 = "./createHeatmap.pl MUC $kw HeatMap_MUC_$datum ../$MUC_2021/Data.csv ../$MUC/Data.csv" ;
my $call2 = "./createHeatmap.pl GER $kw HeatMap_GER_$datum ../$GER_2021/Data.csv ../$GER/Data.csv" ;
print "call: ".$call1."\n";
print `$call1`."\n";
print "call: ".$call2."\n";
print `$call2`."\n";
# print `./createHeatmap.pl GER $kw 'HeatMap_GER_$datum' ../$GER_2021/Data.csv ../$GER/Data.csv`."\n";

print `mv *MUC*.gif ../MUC_GIF/`."\n";
print `mv *GER*.gif ../GER_GIF/`."\n";
# print `mv *MUC*.jpeg ../MUC_JPG/`."\n";
# print `mv *GER*.jpeg ../GER_JPG/`."\n";


# ./createHeatmap.pl MUC 13 '' /Users/neko/Desktop/Covid/Inzidenzen/survstat_MUC_2021_2022_04_01_0600/Data.csv /Users/neko/Desktop/Covid/Inzidenzen/survstat_MUC_2022_04_08_0600/Data.csv

#  ./createHeatmap.pl NRW 9 '' /Users/neko/Desktop/Covid/Inzidenzen/survstat_NRW_2021/Data.csv /Users/neko/Desktop/Covid/Inzidenzen/survstat_NRW_2022_KW9/Data.csv 
