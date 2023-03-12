#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben


my $tar = '/usr/bin/tar';

my $d = 0; # Debugging 0|1

my $MUC_DATA = {
            2020 => 'survstat_MUC_COVID_2020',
            2021 => 'survstat_MUC_COVID_2021',
            2022 => 'survstat_MUC_COVID_2022',
            2023 => 'survstat_MUC_COVID_2023',
};

my $GER_DATA = {
            2020 => 'survstat_GER_COVID_2020',
            2021 => 'survstat_GER_COVID_2021',
            2022 => 'survstat_GER_COVID_2022',
            2023 => 'survstat_GER_COVID_2023',
};


my $dataBase = '/Users/neko/bin/HeatMap/data';
my $outputBase = '/Users/neko/bin/HeatMap/tmp';
my $scriptBase = '/Users/neko/bin/HeatMap/bin';
my $configFile = '/Users/neko/bin/HeatMap/conf/Config.conf';

# go back to scriptDir
chdir $scriptBase;


# 2021
foreach my $kw (1..53){
    my $xkw = sprintf "%02d", $kw;
    my $call1 = "./createHeatmap.pl -c $configFile -o MUC -w $kw -f $outputBase/MUC_GIF/2021$xkw $dataBase/$MUC_DATA->{2020}/Data.csv $dataBase/$MUC_DATA->{2021}/Data.csv" ;
    my $call2 = "./createHeatmap.pl -c $configFile -o GER -w $kw -f $outputBase/GER_GIF/2021$xkw $dataBase/$GER_DATA->{2020}/Data.csv $dataBase/$GER_DATA->{2021}/Data.csv" ;
    print "call: ".$call1."\n\n";
    print `$call1`."\n";
    print "call: ".$call2."\n\n";
    print `$call2`."\n";
}

# 2022
foreach my $y (2022..2023){
    my $lastYear = $y - 1;
    foreach my $kw (1..52){
        my $xkw = sprintf "%02d", $kw;
        my $call1 = "./createHeatmap.pl -c $configFile -o MUC -w $kw -f $outputBase/MUC_GIF/$y$xkw $dataBase/$MUC_DATA->{$lastYear}/Data.csv $dataBase/$MUC_DATA->{$y}/Data.csv" ;
        my $call2 = "./createHeatmap.pl -c $configFile -o GER -w $kw -f $outputBase/GER_GIF/$y$xkw $dataBase/$GER_DATA->{$lastYear}/Data.csv $dataBase/$GER_DATA->{$y}/Data.csv" ;
        print "call: ".$call1."\n\n";
        print `$call1`."\n";
        print "call: ".$call2."\n\n";
        print `$call2`."\n";
    }
}

