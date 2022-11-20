#!/usr/bin/perl

use lib qw( ../lib );

# Tests für HeatMap
# Alle zu usenden Module

# use ExtUtils::MakeMaker # test target nutzen

# ############################
# Vorgeplänkel - Fremdmodule
# ############################

# use Test::Simple tests => 3;
use Test::More;
use Data::Dumper;

my $tests = 0;

# ordered by Priority
my @mods = qw (
                    strict
                    warnings
                    Test::More
                    Exporter
                    Config::Tiny
                    Math::Round
                    Data::Dumper
                    Imager
                    Imager::Fill
                    Neko::HeatMap
                );

foreach my $mo (@mods) {
    use_ok( $mo );
    $tests += 1;
}

# done_testing($tests);
done_testing();

exit 0;

