use strict;
use warnings;

package Acme::Odometer;

use Moo;
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
    default  => quote_sub( q{ 'gif' } ),
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
