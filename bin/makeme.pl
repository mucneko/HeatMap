#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben


my $datum = shift @ARGV // die "kein Datum mitgegeben (z.B. 2022_04_03_0600)";
my $kw = shift @ARGV // 16;
my $tar = '/usr/bin/tar';

my $d = 0; # Debugging 0|1

my $MUC_2021 = 'survstat_MUC_2021_2022_07_13';
my $GER_2021 = 'survstat_GER_2021_2022_07_13';

my $MUC = "survstat_MUC_$datum";
my $GER = "survstat_GER_$datum";

my $dataBase = '/Users/neko/Desktop/Covid/Inzidenzen';
my $scriptBase = '/Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/bin';
my $configFile = '/Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/conf/Config.conf';

print "call: chdir $dataBase\n" if $d;
chdir $dataBase; 
print `pwd`."\n" if $d;

foreach my $dest ( $MUC, $GER ){
print "\n".$dest."\n" if $d;

    if ( !-f "$dest/Data.csv" ){
print "call: mkdir $dest\n" if ( $d && !-d $dest ) ;
        `mkdir $dest`."\n" unless ( -d $dest );
        die "$dest nicht gefunden\n" unless (-d $dest);

print "call: cp $dest.zip $dest \n" if $d;
        print `cp $dest.zip $dest`."\n";
        die "$dest - copy got wrong\n" unless (-f $dest.'/'.$dest.'.zip');
print "call: chdir $dest \n" if $d;
        chdir $dest || die $!;

print "call: $tar vxfz $dest.zip\n" if $d;
          print `$tar vxfz $dest.zip` ."\n";
print "call: rm $dest.zip\n" if $d;
          print `rm $dest.zip`."\n";
print "call: chdir $dataBase\n" if $d;
          chdir $dataBase;
    }
}

# chdir 'bin/';
print " ENDE call: chdir $scriptBase\n" if $d;
chdir $scriptBase;


# print `pwd`;
# print <<EOF;
  # dataBase: $dataBase
# scriptBase: $scriptBase
# configFile: $configFile
# EOF

my $call1 = "./createHeatmap.pl -c $configFile -o MUC -w $kw -f HeatMap_MUC_$datum\_$kw\_neu $dataBase/$MUC_2021/Data.csv $dataBase/$MUC/Data.csv" ;
my $call2 = "./createHeatmap.pl -c $configFile -o GER -w $kw -f HeatMap_GER_$datum\_$kw\_neu $dataBase/$GER_2021/Data.csv $dataBase/$GER/Data.csv" ;
# my $call2 = "./createHeatmap.pl GER $kw HeatMap_GER_$datum ../$GER_2021/Data.csv ../$GER/Data.csv" ;
print "call: ".$call1."\n\n";
print `$call1`."\n";
print "call: ".$call2."\n\n";
print `$call2`."\n";


# print `pwd`;
my $call = "mv *MUC*.gif $dataBase/MUC_GIF/";
print "call: $call\n";
`$call`;
$call = "mv *GER*.gif $dataBase/GER_GIF/";
print "call: $call\n";
`$call`;


# ./createHeatmap.pl -c /Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/conf/Config.conf -o MUC -w 46 -f HeatMap_MUC_2022_11_19_46 /Users/neko/Desktop/Covid/Inzidenzen/survstat_MUC_2021_2022_07_13/Data.csv /Users/neko/Desktop/Covid/Inzidenzen/survstat_MUC_2022_11_19/Data.csv
