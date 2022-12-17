#!/usr/bin/perl

use strict;
use warnings;

use Date::Calc qw( :all );

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                            localtime(time);
$year = $year+1900;
$mon += 1;
my ($kw, $wyear) = Week_of_Year($year,$mon,$mday);

my $kwOrig =$kw;
$kw -= 1;
$kw = Weeks_in_Year( ($year-1)) unless $kw;

print " $year $mon $mday - kw: $kw, $wyear\n";

my $call1 = "./get_csv.pl $year\_$mon\_$mday 2>&1 1 > ../tmp/$year\_$mon\_$mday\_$kw\.txt";
my $call2 = "./makeme.pl $year\_$mon\_$mday $kw 2>&1 1 >> ../tmp/$year\_$mon\_$mday\_$kw\.txt";

my $call3 = "./makeme.pl $year\_$mon\_$mday $kwOrig 2>&1 1 >> ../tmp/$year\_$mon\_$mday\_$kw\.txt";

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
