use Data::Adsense ':all';
my $data = read_adsense ('report.csv');
my @monthly = $data->per_month ();
for (@monthly) {
    print "You earned $_->[earnings_col] in $_->[date_col]\n";
}
