#!/usr/bin/perl
use strict;
use warnings;

use lib qw(
            /Users/neko/perl5/lib/perl5/darwin-thread-multi-2level
            /Users/neko/perl5/lib/perl5
        );


use Math::Round qw( nearest nlowmult );
use Data::Dumper;
# use Encoding qw(decode encode);

use Imager;
use Imager::Fill;
# use Imager::Font;

my $indir = shift || useageanddie( "kein Directory bekommen" );
my $use_this_outputname = shift // 'anim_test';

my @files = ();
my @images = ();
opendir ( DIR, $indir ) || die "Error in opening dir $indir\n";

while( ( my $filename = readdir(DIR))) {
    push @files, $filename;
}
closedir(DIR);


foreach my $file ( sort @files ){
    next unless $file;
    next if $file =~ /^\.+/;
    next if $file =~ /^\.DS/;

    print("verwende: $indir/$file\n");
    my $image = Imager->new;
    $image->read(file => $indir.'/'.$file) or die $image->errstr;

    push @images, $image;
}

my $filename = $use_this_outputname.'.gif';
print "output: $filename\n";

Imager->write_multi({ file=>$filename, type=>'gif' }, @images)
    or die Imager->errstr;

sub usageanddie
{
    my $msg = shift // '';
    print "ERROR: $msg\n" if $msg;

    print <<EOF;

usage: $0 <indir> [outputfilename]

creates an animated gif from all image in <indir>, sorted by name(!)
fallback if no outputfile is given: anim_test.gif
EOF

    exit 1;
}

exit 0;
