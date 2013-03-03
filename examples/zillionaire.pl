use Data::Adsense ':all';
my $data = read_adsense ('report.csv');
my @rows = $data->rows ();
my $max = -1;
my $mrow = -1;
for my $i (0..$#rows) {
    my $e = $rows[$i][earnings_col];
    if ($e > $max) {
        $mrow = $i;
        $max = $e;
    }
}
print "You reached a maximum on $rows[$mrow][date_col] with the princely sum of $max.\n";

