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

`$cucumber features/get_csv_MUC.feature`;
`mv survstat.zip $zip_dir/survstat_MUC_$datum\.zip`;
`$cucumber features/get_csv_GER.feature`;
`mv survstat.zip $zip_dir/survstat_GER_$datum\.zip`;

chdir '../' || die $!;

exit 0;
