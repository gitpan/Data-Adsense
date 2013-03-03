package Data::Adsense::MonthFraction;
use parent Exporter;
our @EXPORT_OK = qw/month_fraction/;
use warnings;
use strict;
use Carp;
use DateTime;

sub month_fraction
{
    my ($dt) = @_;
    if (! defined $dt) {
        $dt = DateTime->now ();
    }
    $dt->set_time_zone ('America/Los_Angeles');
    my $month = $dt->month;
    my $year = $dt->year;
    my $mday = $dt->day_of_month;
    my $days_so_far = ($mday - 1) + (($dt->minute / 60) + $dt->hour) / 24;
    # Get the days in the month.
    my $days = DateTime->last_day_of_month (
        year => $year,
        month => $month,
    )->day ();
    #print "There are $days days in $month. Today is day $mday.\n";
    my $fraction = ($days / $days_so_far);
    if (wantarray ()) {
        # Undocumented.
        return ($fraction, $days, $days_so_far);
    }
    else {
        return $fraction;
    }
}

1;

