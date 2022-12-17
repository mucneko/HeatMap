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
my $zip_dir = '/Users/neko/Desktop/Covid/Inzidenzen';

my $cucumber = '/Users/neko/.rvm/gems/ruby-3.0.0/bin/cucumber';

print "call: chdir $dest \n" if $d;
chdir $dest || die $!;


`$cucumber features/get_version.feature`;
`cat page_debug1.html`;

my @Currents = split ("\n",`grep Current page_debug1.html`);
my $fst = shift @Currents;
my( $year, $month, $day ) = ('','','');
print $fst."\n";
if ( $fst =~ /selected\=\"selected\".*Current \(([0-9]{4})\-([0-9]{2})\-([0-9]{2}) / ) {
print "matches\n";
    $year = $1;
    $month = $2;
    $day = $3;
}

if ( $datum ne $year.'_'.$month.'_'.$day ) {
    die "$datum ne $year\_$month\_$day -> exit \n";
}


`$cucumber features/get_csv_GER.feature`;
`mv survstat.zip $zip_dir/survstat_GER_$datum\.zip`;

`$cucumber features/get_csv_MUC.feature`;
`mv survstat.zip $zip_dir/survstat_MUC_$datum\.zip`;

`$cucumber features/get_csv_MUC_inzidenz.feature`;
`mv survstat.zip $zip_dir/survstat_MUC_$datum\_inzidenz.zip`;

`$cucumber features/get_csv_MUC_anzahl.feature`;
`mv survstat.zip $zip_dir/survstat_MUC_$datum\_anzahl.zip`;

chdir '../' || die $!;

exit 0;