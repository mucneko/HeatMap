#!/usr/bin/perl

use strict;
use warnings;

use Date::Calc qw( :all );

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                            localtime(time);
my $indatum = shift || '';
my $inkw = shift || '';
my $datum = '';

$year = $year+1900;
$mon += 1;
my ($kw, $wyear) = Week_of_Year($year,$mon,$mday);

my $kwOrig =$kw;
$kw -= 1;
$kw = Weeks_in_Year( ($year-1)) unless $kw;

$datum = "$year\_$mon\_$mday";
$datum = $indatum if ( $indatum );
$kw = $inkw if ( $inkw );

print " $year $mon $mday - kw: $kw, $wyear\n";

if ( -f "/Users/neko/bin/HeatMap/data/MUC_GIF/HeatMap_MUC_$datum\_$kw\_neu.gif" ) {
    die "/Users/neko/bin/HeatMap/data/MUC_GIF/HeatMap_MUC_$datum\_$kw\_neu.gif gibts schon, Programm ist schon mal gelaufen -\> exit\n";
}
else {
    print "$_ /Users/neko/bin/HeatMap/data/MUC_GIF/HeatMap_MUC_$datum\_$kw\_neu.gif nicht gefunden\nIch schau mal, was geht.\n";
}

# cleanup
if ( -f '/Users/neko/bin/HeatMap/bin/get_csv/survstat.zip.crdownload' ) {
    print "$_ unlinke '/Users/neko/bin/HeatMap/bin/get_csv/survstat.zip.crdownload'\n";
    unlink '/Users/neko/bin/HeatMap/bin/get_csv/survstat.zip.crdownload';
}


my $call1 = "./get_csv.pl $datum 2>&1 1 >> ../tmp/$datum\_$kw\.txt";
my $call2 = "./makeme.pl $datum $kw 2>&1 1 >> ../tmp/$datum\_$kw\.txt";

my $call3 = "./makeme.pl $datum $kwOrig 2>&1 1 >> ../tmp/$datum\_$kw\.txt";

print "call: $call1\n";
system ( $call1 );
if ( $? ){
    print $?."\n";
    exit 0;
}

print "call: $call2\n";
system ( $call2 );
if ( $? ){
    print $?."\n";
    exit 0;
}

print "call: $call3\n";
system ( $call3 );
if ( $? ){
    print $?."\n";
    exit 0;
}

exit 0;
