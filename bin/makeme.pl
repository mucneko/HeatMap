#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben


my $datum = shift @ARGV // die "kein Datum mitgegeben (z.B. 2022_04_03_0600)";
my $kw = shift @ARGV // 53;
my $tar = '/usr/bin/tar';

my $d = 0; # Debugging 0|1

my $MUC_2021 = 'survstat_MUC_COVID_2021';
my $GER_2021 = 'survstat_GER_COVID_2021';
my $MUC_2022 = 'survstat_MUC_COVID_2022';
my $GER_2022 = 'survstat_GER_COVID_2022';

my $MUC = "survstat_MUC_$datum";
my $GER = "survstat_GER_$datum";

my $dataBase = '/Users/neko/bin/HeatMap/data';
my $scriptBase = '/Users/neko/bin/HeatMap/bin';
my $configFile = '/Users/neko/bin/HeatMap/conf/Config.conf';

print "call: chdir $dataBase\n" if $d;
chdir $dataBase; 
print `pwd`."\n" if $d;

# unpack each .zip into an own directory with same name
foreach my $dest ( $MUC, $GER ){
print "\n".$dest."\n" if $d;

    if ( !-f "$dest/Data.csv" ){
print "call: mkdir $dest\n" if ( $d && !-d $dest ) ;
        `mkdir $dest` unless ( -d $dest );
        die "$dest nicht gefunden\n" unless (-d $dest);

print "call: cp $dest.zip $dest \n" if $d;
        print `cp $dest.zip $dest`."\n";
        die "$dest - copy got wrong\n" unless (-f $dest.'/'.$dest.'.zip');
print "call: chdir $dest \n" if $d;
        chdir $dest || die $!;

print "call: $tar vxfz $dest.zip\n" if $d;
          # there is some option to name the destination, ich bin faul, so gehts auch.
          print `$tar vxfz $dest.zip` ."\n";

print "call: rm $dest.zip\n" if $d;
          # double zipfile is waste
          print `rm $dest.zip`."\n";
print "call: chdir $dataBase\n" if $d;
          chdir $dataBase;
    }
}

# chdir 'bin/';
print " ENDE call: chdir $scriptBase\n" if $d;

# go back to scriptDir
chdir $scriptBase;


# print `pwd`;
# print <<EOF;
  # dataBase: $dataBase
# scriptBase: $scriptBase
# configFile: $configFile
# EOF

# call createHeatmap.pl with all its lovely options.
my $call1 = "./createHeatmap.pl -c $configFile -o MUC -w $kw -f HeatMap_MUC_$datum\_$kw\_neu $dataBase/$MUC_2022/Data.csv $dataBase/$MUC/Data.csv" ;
my $call2 = "./createHeatmap.pl -c $configFile -o GER -w $kw -f HeatMap_GER_$datum\_$kw\_neu $dataBase/$GER_2022/Data.csv $dataBase/$GER/Data.csv" ;
# my $call2 = "./createHeatmap.pl GER $kw HeatMap_GER_$datum ../$GER_2022/Data.csv ../$GER/Data.csv" ;
print "call: ".$call1."\n\n";
print `$call1`."\n";
print "call: ".$call2."\n\n";
print `$call2`."\n";


# move pictures into their directories
# print `pwd`;
my $call = "mv *MUC* $dataBase/MUC_GIF/";
print "call: $call\n";
`$call`;
$call = "mv *GER* $dataBase/GER_GIF/";
print "call: $call\n";
`$call`;


