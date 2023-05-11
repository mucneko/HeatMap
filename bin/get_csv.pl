#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

my $datum = shift @ARGV // die "kein Datum mitgegeben (z.B. 2022_04_03)";
my $d = 0;

my $dest = 'get_csv';
my $MUC_ZIP = 'get_csv_MUC.feature';
my $GER_ZIP = 'get_csv_GER.feature';
my $zip_dir = '/Users/neko/bin/HeatMap/data/';

my $cucumber = '/Users/neko/.rvm/gems/ruby-3.0.0/bin/cucumber';

print "call: chdir $dest \n" if $d;
chdir $dest || die $!;


`$cucumber features/get_version.feature`;
`cat get_feature.html`;

my @Currents = split ("\n",`grep Current get_feature.html`);

# print "Currents @Currents\n";
my $fst = shift @Currents;
my( $year, $month, $day ) = ('','','');
print $fst."\n";

if ( $fst =~ /selected\=\"selected\".*Current \(([0-9]{4})\-([0-9]{2})\-([0-9]{2}) / ) {
# if ( $fst =~ /selected\=\"selected\".*Aktuell \(([0-9]{4})\-([0-9]{2})\-([0-9]{2}) / ) {
print "matches\n";
    $year = $1;
    $month = $2;
    $day = $3;
}

if ( $datum ne $year.'_'.$month.'_'.$day ) {
    die "$datum ne $year\_$month\_$day -> exit \n";
}

if ( -f 'survstat.zip.crdownload' ) {
    print STDERR 'survstat.zip.crdownload vom letzten Lauf gefunden - entferne es'."\n";
    unlink 'survstat.zip.crdownload';
}

`$cucumber features/get_csv_GER.feature`;

my $cnt = 0;
while ( -f 'survstat.zip.crdownload' ){
    die "$cnt gewartet, survstat.zip.crdownload gibts noch immer - fishy\n" if $cnt > 240;
    $cnt += 1;
    sleep 1;
}
`mv survstat.zip $zip_dir/survstat_GER_$datum\.zip`;

`$cucumber features/get_csv_MUC.feature`;
$cnt = 0;
while ( -f 'survstat.zip.crdownload' ){
    die "$cnt gewartet, survstat.zip.crdownload gibts noch immer - fishy\n" if $cnt > 240;
    $cnt += 1;
    sleep 1;
}
`mv survstat.zip $zip_dir/survstat_MUC_$datum\.zip`;

`$cucumber features/get_csv_MUC_inzidenz.feature`;
$cnt = 0;
while ( -f 'survstat.zip.crdownload' ){
    die "$cnt gewartet, survstat.zip.crdownload gibts noch immer - fishy\n" if $cnt > 240;
    $cnt += 1;
    sleep 1;
}
`mv survstat.zip $zip_dir/survstat_MUC_$datum\_inzidenz.zip`;

`$cucumber features/get_csv_MUC_anzahl.feature`;
$cnt = 0;
while ( -f 'survstat.zip.crdownload' ){
    die "$cnt gewartet, survstat.zip.crdownload gibts noch immer - fishy\n" if $cnt > 240;
    $cnt += 1;
    sleep 1;
}
`mv survstat.zip $zip_dir/survstat_MUC_$datum\_anzahl.zip`;

chdir '../' || die $!;

exit 0;
