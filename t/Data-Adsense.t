# This is a test for module Data::Adsense.

use warnings;
use strict;
use Test::More;
use Data::Adsense 'read_adsense';
use FindBin;

my $data = read_adsense ("$FindBin::Bin/test-file.txt");
ok ($data);
my @rows = $data->date_earnings ();
ok (@rows);
done_testing ();

# Local variables:
# mode: perl
# End:
