use Test::Most;

use Acme::Odometer;
use Path::Class qw(file);

my $path = file( 'assets', 'odometer' )->stringify;
my $counter = Acme::Odometer->new( asset_path => $path );

ok( $counter,                        'loads and creates' );
ok( $counter->image( '0123456789' ), 'got an image' );
ok( $counter->image( 0 ), 'got image for 0' );

done_testing();
