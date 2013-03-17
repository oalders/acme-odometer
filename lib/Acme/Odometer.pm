use strict;
use warnings;

package Acme::Odometer;

use Moo 1.001;
use MooX::Types::MooseLike::Numeric qw(PositiveInt);

use Devel::Dwarn;
use GD;
use Memoize;
use Path::Class qw( file );
use Sub::Quote qw( quote_sub );
use namespace::autoclean;

memoize( '_digit_as_image' );

has asset_path => (
    is       => 'ro',
    required => 1,
);

has digit_height => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    lazy     => 1,
    builder  => '_build_height',
);

has digit_width => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    lazy     => 1,
    builder  => '_build_width',
);

has file_extension => (
    is       => 'ro',
    required => 0,
    default  => 'gif',
);

has _i => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    init_arg => undef,
    writer   => '_set_i',
);

has _first_image => (
    is       => 'ro',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_first_image',
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

    my $total_width = $self->digit_width * length $self->_i;
    my $im          = GD::Image->new( $total_width, $self->digit_height );
    my $percent     = 100;

    my $pos = 0;
    foreach my $digit ( split //, $self->_i ) {
        $im->copyMergeGray(
            $self->_digit_as_image( $digit ),
            $pos * $self->digit_width,
            0, 0, 0, $self->digit_width, $self->digit_height, $percent
        );
        $pos++;
    }

    return $im;
}

1;

# ABSTRACT: Create graphical web counters

=head1 DESCRIPTION

Create old school graphical counters.

=head1 SYNOPSIS

    use Acme::Odometer;

    my $retro = Acme::Odometer->new( asset_path => 'path/to/digit/files' );

    binmode STDOUT;
    print $retro->image( '000123456789' )->png;


    # or, write the image to a file for your viewing pleasure
    use Acme::Odometer;
    use File::Slurp qw( write_file );

    my $retro = Acme::Odometer->new( asset_path => 'path/to/digit/files' );
    my $image = $retro->image( '000123456789' );

    # write as a GIF
    write_file( "counter.gif", $image->gif );

    # write as a PNG
    write_file( "counter.png", $image->png );


=head1 CONSTRUCTOR AND STARTUP

=head2 new()

Creates and returns a new Acme::Odometer object.

=over 4

=item * C<< asset_path => "/path/to/odometer/files" >>

The path to your asset folder.  The asset folder will contain 0..9 image files
of equal width, named 0.gif, 1.gif, 2.gif, 3.gif etc.  The images can be in any
format which GD can read.  You may configure the file extension of your assets
via the C<file_extension> param.

=item * C<< file_extension >>

The extension of the files in your asset directory: "gif", "GIF", "png", "jpg",
"jpg", etc.  This module makes no assumptions about what is or is not a valid
extension.  Defaults to "gif".

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

All you need to get started is the images.  The images should consist of the
digits 0-9, all in the same file format and all of equal width.  For example,
see L<http://digitmania.birdbrain.net/> for a bunch of insanely retro counter
graphics.  Or, see the assets folder of this distribution for a basic odometer.

=cut
