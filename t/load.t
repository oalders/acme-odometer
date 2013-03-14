use Test::Most;

use Acme::Odometer;

my $counter = Acme::Odometer->new();
ok( $counter, "loads and creates" );

done_testing();
