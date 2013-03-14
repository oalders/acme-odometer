use strict;
use warnings;

package Acme::Odometer;

use Moo;
use GD;

has asset_path => (
    is  => 'ro',
    isa => 'Str',
);

1;

# ABSTRACT: Create graphical web counters
