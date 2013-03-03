use Data::Adsense ':all';
my $data = read_adsense ('report.csv');
my @rows = $data->rows ();
for (@rows) {
    print "On $_->[date_col], you earned ¥$_->[earnings_col].\n";
}
