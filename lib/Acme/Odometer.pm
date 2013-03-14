use strict;
use warnings;

package Acme::Odometer;

use Moo;
use MooX::Types::MooseLike::Numeric qw(PositiveInt);

use Devel::Dwarn;
use Devel::SimpleTrace;
use GD;
use Path::Class qw( file );

has asset_path => (
    is       => 'ro',
    required => 1,
);

has width => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    lazy     => 1,
    builder  => '_build_width',
);

has height => (
    is       => 'ro',
    isa      => PositiveInt,
    required => 0,
    lazy     => 1,
    builder  => '_build_height',
);

has _sample_asset => (
    is       => 'ro',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_sample_asset',
);

sub _build_width {
    my $self = shift;
    return $self->_sample_asset->width;
}

sub _build_height {
    my $self = shift;
    return $self->_sample_asset->height;
}

sub _build_sample_asset {
    my $self = shift;
    return GD::Image->new( file( $self->asset_path, "0.gif" )->stringify );
}

sub image {
    my $self = shift;
    my $i    = shift;
    die "not a number" if $i =~ m{[^0-9]};

    my @digits = split //, $i;

    my $total_width = $self->width * length $i;
    my $im          = GD::Image->new( $total_width, $self->height );
    my $percent     = 100;

    my $path = file( $self->asset_path, "1.gif" );
    my $pos = 0;
    foreach my $digit ( split //, $i ) {
        my $digit_as_image = GD::Image->new(
            file( $self->asset_path, "$digit.gif" )->stringify );
        $im->copyMergeGray( $digit_as_image, $pos * $self->width,
            0, 0, 0, $self->width, $self->height, $percent );
        $pos++;
    }

    return $im;
}

1;

# ABSTRACT: Create graphical web counters
