use Data::Adsense ':all';
my $data = read_adsense ('report.csv');
my @weekly = $data->per_week (1);
for (@weekly) {
    printf "You had CTR of %.3g%% in week $_->[date_col]\n", $_->[ctr_col];
}
