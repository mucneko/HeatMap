#!/usr/bin/perl
use strict;
use warnings;

use lib qw(
            /Users/neko/perl5/lib/perl5/darwin-thread-multi-2level
            /Users/neko/perl5/lib/perl5
        );

# scale images to something in the range of: 600x800 / 800x600

use Math::Round qw( nearest nlowmult );
use Data::Dumper;
# use Encoding qw(decode encode);

use Imager;
use Imager::Fill;
# use Imager::Font;

my $infile = shift || usageanddie( "kein file bekommen" );
my $use_this_outputname = shift // 'mast';

print("verwende: $infile\n");
my $image = Imager->new;
$image->read(file => $infile) or die $image->errstr;


my $fn = $use_this_outputname.'.gif';
print "output: $fn\n";

my $newimg = $image->scale(xpixels=>800,ypixels=>600,type=>'min');

# Check if given format is supported
if ( $Imager::formats{'gif'} ) {
    
    $newimg->write( file=>$fn );
    if ( $newimg->errstr ) {
        die "Fehler beim exportieren: ".$newimg->errstr ."\n";
    }
    # $saved = 1;

}

sub usageanddie
{
    my $msg = shift // '';
    print "ERROR: $msg\n" if $msg;

    print <<EOF;

usage: $0 <infile> [<outputfile>]

scales the given image to something in range of 800x600 and stores it in the gifen outputfile
fallback if no output filename is provided: mast.gif
EOF

    exit 1;
}

exit 0;
