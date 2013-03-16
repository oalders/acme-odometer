#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Acme::Odometer;
use File::Slurp qw( write_file );
use Path::Class qw(file);

my $path = file( 'assets', 'odometer' )->stringify;
my $counter = Acme::Odometer->new( asset_path => $path );

write_file( "test.gif", $counter->image( '000123456789' )->gif );

=pod

=head1 SYNOPSIS

# create a test.gif file in the top folder
perl -Ilib examples/write_gif.pl

=cut
