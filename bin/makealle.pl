#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben


# my $datum = shift @ARGV // die "kein Datum mitgegeben (z.B. 2022_04_03_0600)";
# my $kw = shift @ARGV // 16;
my $tar = '/usr/bin/tar';

my $d = 0; # Debugging 0|1

my $MUC_2020 = 'survstat_MUC_COVID_2020';
my $MUC_2021 = 'survstat_MUC_COVID_2021';
my $MUC_2022 = 'survstat_MUC_COVID_2022';

my $GER_2020 = 'survstat_GER_COVID_2020';
my $GER_2021 = 'survstat_GER_COVID_2021';
my $GER_2022 = 'survstat_GER_COVID_2022';


my $dataBase = '/Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/tmp';
my $scriptBase = '/Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/bin';
my $configFile = '/Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/conf/Config.conf';

# go back to scriptDir
chdir $scriptBase;


# 2021
foreach my $kw (1..53){
    my $xkw = sprintf "%02d", $kw;
    my $call1 = "./createHeatmap.pl -c $configFile -o MUC -w $kw -f $dataBase/MUC_GIF/2021$xkw $dataBase/$MUC_2020/Data.csv $dataBase/$MUC_2021/Data.csv" ;
    my $call2 = "./createHeatmap.pl -c $configFile -o GER -w $kw -f $dataBase/GER_GIF/2021$xkw $dataBase/$GER_2020/Data.csv $dataBase/$GER_2021/Data.csv" ;
    print "call: ".$call1."\n\n";
    print `$call1`."\n";
    print "call: ".$call2."\n\n";
    print `$call2`."\n";
}

# 2022
foreach my $kw (1..52){
    my $xkw = sprintf "%02d", $kw;
    my $call1 = "./createHeatmap.pl -c $configFile -o MUC -w $kw -f $dataBase/MUC_GIF/2022$xkw $dataBase/$MUC_2021/Data.csv $dataBase/$MUC_2022/Data.csv" ;
    my $call2 = "./createHeatmap.pl -c $configFile -o GER -w $kw -f $dataBase/GER_GIF/2022$xkw $dataBase/$GER_2021/Data.csv $dataBase/$GER_2022/Data.csv" ;
    print "call: ".$call1."\n\n";
    print `$call1`."\n";
    print "call: ".$call2."\n\n";
    print `$call2`."\n";
}



# ./createHeatmap.pl -c /Users/neko/Desktop/Covid/Inzidenzen/bin/HeatMap/conf/Config.conf -o MUC -w 46 -f HeatMap_MUC_2022_11_19_46 /Users/neko/Desktop/Covid/Inzidenzen/survstat_MUC_2021_2022_07_13/Data.csv /Users/neko/Desktop/Covid/Inzidenzen/survstat_MUC_2022_11_19/Data.csv
