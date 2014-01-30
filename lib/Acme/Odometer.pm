use strict;
use warnings;

package Acme::Odometer;

use Moo 1.001;
use MooX::Types::MooseLike::Numeric qw(PositiveInt);

use GD;
use Memoize;
use Path::Class qw( file );
use namespace::autoclean;

memoize( '_digit_as_image' );

has asset_path => (
    is       => 'ro',
    required => 1,
);

has file_extension => (
    is       => 'ro',
    required => 0,
    default  => 'gif',
);

has _digit_height => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    lazy     => 1,
    builder  => '_build_height',
);

has _digit_width => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    lazy     => 1,
    builder  => '_build_width',
);

has _first_image => (
    is       => 'ro',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_first_image',
);

has _i => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    init_arg => undef,
    writer   => '_set_i',
);

sub _build_width {
    my $self = shift;
    return $self->_first_image->width;
}

sub _build_height {
    my $self = shift;
    return $self->_first_image->height;
}

sub _build_first_image {
    my $self = shift;
    return $self->_digit_as_image( substr( $self->_i, 0, 1 ) );
}

sub _digit_as_image {
    my $self = shift;
    my $digit = sprintf( "%i.%s", shift(), $self->file_extension );
    return GD::Image->new( file( $self->asset_path, $digit )->stringify );
}

sub image {
    my $self = shift;
    $self->_set_i( shift() );

    my $total_width = $self->_digit_width * length $self->_i;
    my $im          = GD::Image->new( $total_width, $self->_digit_height );
    my $percent     = 100;

    my $pos = 0;
    foreach my $digit ( split //, $self->_i ) {
        $im->copyMergeGray(
            $self->_digit_as_image( $digit ),
            $pos * $self->_digit_width,
            0, 0, 0, $self->_digit_width, $self->_digit_height, $percent
        );
        $pos++;
    }

    return $im;
}

1;

# ABSTRACT: Create graphical web counters

=head1 DESCRIPTION

This is a BETA release.  The interface is still subject to change.

Acme::Odometer makes it easy to produce graphical web counters. You know, those
odometer style thingies you used to see on a lot of geocities pages?  This
module takes a bunch of images of different digits, strings them together and
passes them back to you as a GD::Image object.

=head1 SYNOPSIS

    # write the image to a file for your viewing pleasure
    use Acme::Odometer;
    use File::Slurp qw( write_file );

    my $odometer = Acme::Odometer->new(
        asset_path     => 'path/to/digit/files',
        file_extension => 'png',
    );

    my $image = $odometer->image( '000123456789' );

    # write as a GIF
    write_file( "counter.gif", $image->gif );

    # write as a PNG
    write_file( "counter.png", $image->png );


    # or (for example) in a Dancer app
    # place an odometer graphic at /counter?count=12345
    # in real life, you'll want to validate etc before creating the graphic

    get '/counter' => sub {
        header( 'Content-Type' => 'image/png' );
        my $odometer = Acme::Odometer->new(
            asset_path     => 'path/to/digit/files',
            file_extension => 'png',
        );
        $odometer->image( params->{count} )->png;
    };


=head1 CONSTRUCTOR AND STARTUP

=head2 new()

Creates and returns a new Acme::Odometer object.  The following parameters can
be passed to new().

=over 4

=item * C<< asset_path => "/path/to/odometer/files" >>

The path to your asset folder.  The asset folder will contain 0..9
image files of equal width, named 0.gif, 1.gif, 2.gif, 3.gif etc.  The images
can be in any format which GD can read.  This parameter is required.

=item * C<< file_extension => 'png' >>

The extension of the files in your asset directory: "gif", "GIF", "png", "jpg",
"jpeg", etc.  This module makes no assumptions about what is or is not a valid
extension.  This parameter is optional and defaults to "gif".

    my $odometer = Acme::Odometer->new(
        asset_path     => 'path/to/digit/files',
        file_extension => 'png',
    );

=back

=head2 image

Returns a GD::Image object, which you can use to print your image

    my $odometer = Acme::Odometer->new(
        asset_path     => 'path/to/digit/files',
        file_extension => 'png',
    );

    binmode STDOUT;
    print $odometer->image->png;

=head1 RESOURCES

All you need to get started is the images, which should consist of the digits
0-9, all in the same file format and all of equal width.  For example, see
L<http://digitmania.birdbrain.net/> for a bunch of insanely retro counter
graphics.  Or, see the assets folder of this distribution for a basic odometer.

=head1 ACKNOWLEDGEMENTS

It's hard to trace the history of a lot of web counter graphics which have been
circulated as they seem to originate in the Wild West of the internet.  The
images bundled with this dist appear to have been created by Heini Withagen,
but this is hard to verify since the original page 404s now and also 404s in
the earliest wayback machine snapshot (1999).  Original link found at
L<http://www.ugrad.cs.ubc.ca/spider/q6e192/cgi/COUNTER.HTM>.

=cut
