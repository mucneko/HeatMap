#!/usr/bin/perl


# Tests für iTop.pm
# einfach mal systematisch durchtesten (Selbst-Test)

# use ExtUtils::MakeMaker # test target nutzen

# ######################################################################
# Vorgeplänkel - Fremdmodule
# ######################################################################

use Test::More;
use_ok( 'Test::More' );
require_ok( 'Test::More' );

use Test::Simple; # tests => 'no plan';
use_ok( 'Test::Simple' );
require_ok( 'Test::Simple' );

use Test::Harness;
use_ok( 'Test::Harness' );
require_ok( 'Test::Harness' );

use Data::Dumper;
use_ok( 'Data::Dumper' );
$Data::Dumper::Sortkeys = 1;   # Dumperdaten sortiert (sort) ausgeben

# ######################################################################
# Rest in externen Files ausgelagert
# ######################################################################

my @test_files = qw (
                      new.t
                      uses.t
                      hmF_getConfig.t
                      HeatMap::getConfig.t
                      HeatMap::setConfig.t
                      hmF_loadColorMap.t
                      HeatMap::getColorMap.t
                    );

runtests(@test_files);
# my ($total, $failed ) = Test::Harness::execute_tests( tests => \@test_files );
# print Dumper($total) if $total;
# print Dumper($failed) if $failed;

done_testing(12);

exit 0;

