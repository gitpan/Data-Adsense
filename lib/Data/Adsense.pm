package Data::Adsense;
require Exporter;
@ISA = qw(Exporter);

# Column names

use constant {
    date_col => 0,
    views_col => 1,
    clicks_col => 2,
    ctr_col => 3,
    cpc_col => 4,
    rpm_col => 5,
    earnings_col => 6,
    days_col => 7,
    n_columns => 7,
};


@EXPORT_OK = qw/
      read_adsense
      rpm
      ctr
      cpc
      date_col
      views_col
      clicks_col
      ctr_col
      cpc_col
      rpm_col
      earnings_col
/;

%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
use warnings;
use strict;
use Carp;
use Date::Calc 'Day_of_Week';
use Scalar::Util 'looks_like_number';
our $VERSION = 0.01;

sub read_adsense
{
    my ($file_name) = @_;
    if (! -f $file_name) {
        croak "Cannot find file '$file_name'";
    }
    my $data = {};
    open my $fh, "<:crlf:encoding(utf-16le)", $file_name
        or croak "Error opening '$file_name': $!";
    my $titles = <$fh>;
    my @titles = split /\t/, $titles;
    $data->{titles} = \@titles;
    my @rows;
    while (my $row = <$fh>) {
        $row =~ s/\s+$//;
        if ($row =~ /^\s*$/) {
            next;
        }
        my @cols = split /\t/, $row;
        if (! @cols) {
            next;
        }
        $cols[ctr_col] =~ s/%$//;
        push @rows, \@cols;
    }
    close $fh or die $!;
    $data->{rows} = \@rows;
    bless $data;  
}

# Undocumented.

sub date_earnings
{
    my ($data) = @_;
    if (! $data->{rows}) {
        croak "No data for rows";
    }
    if (! wantarray) {
        croak "This routine returns an array value";
    }
    my @r;
    for my $r (@{$data->{rows}}) {
        push @r, [$r->[date_col], $r->[earnings_col]];
    }
    return @r;
}

sub titles
{
    my ($data) = @_;
    if (! $data->{titles}) {
        croak "No titles found.";
    }
    if (! wantarray) {
        croak "This routine returns an array value";
    }
    return @{$data->{titles}};
}

sub rows
{
    my ($data) = @_;
    if (! $data->{rows}) {
        croak "No titles found.";
    }
    if (! wantarray) {
        croak "This routine returns an array value";
    }
    return @{$data->{rows}};
}

sub per_month
{
    if (! wantarray) {
        croak "This routine returns an array value";
    }
    my ($data) = @_;
    my @per_month;
    my $this_month;
    my $prev_month = -1;
    my @rows = $data->rows ();
    for my $row (@rows) {
        my @cols = @$row;
        my @ymd = split /\D/, $cols[0];
        my $month = $ymd[1];
        if ($month != $prev_month) {
            $prev_month = $month;
            $this_month = [(0) x (1 + n_columns)];
            $this_month->[date_col] = $ymd[0] . '-' . $month;
            push @per_month, $this_month;
        }
        add (\@cols, $this_month);
    }
    recalculate (\@per_month);
    return @per_month;
}

sub per_week
{
    if (! wantarray) {
        croak "This routine returns an array value";
    }
    my ($data, $firstdow) = @_;
    if (! defined $firstdow) {
        # This is what Google uses in the "per week" display in
        # Adsense.
        $firstdow = 1;
    }
    if ($firstdow < 1 || $firstdow > 7) {
        croak "$firstdow cannot be the first day of the week; use a number between one and seven";
    }
    my @per_week;
    my $this_week;
    my $prev_week = 0;
    my @rows = $data->rows ();
    my $yesterday;
    for my $row (@rows) {
        my @cols = @$row;
        my @ymd = split /\D/, $cols[0];
        my $weekday = Day_of_Week (@ymd);
        if ($prev_week == 0 || $weekday == $firstdow) {
            $prev_week++;
            end_week ($this_week, $yesterday);
            $this_week = [(0) x (1 + n_columns)];
            $this_week->[date_col] = $prev_week . ' [' . $cols[0];
            push @per_week, $this_week;
        }
        add (\@cols, $this_week);
        $yesterday = $cols[0];
    }
    end_week ($this_week, $yesterday);
    recalculate (\@per_week);
    return @per_week;
}

sub end_week
{
    my ($this_week, $yesterday) = @_;
    if ($this_week) {
        $this_week->[date_col] .= ' - ' . $yesterday . ']';
    }
}

# Recalculate the cpc, ctr, and rpm using the data we got.

sub recalculate
{
    my ($per_period) = @_;
    for my $p (@$per_period) {
        $p->[cpc_col] = cpc ($p->[earnings_col], $p->[clicks_col]);
        $p->[ctr_col] = ctr ($p->[clicks_col], $p->[views_col]);
        $p->[rpm_col] = rpm ($p->[earnings_col], $p->[views_col]);
    }
}

sub validate
{
    for (@_) {
        if (! looks_like_number ($_)) {
            croak "$_ does not look like a number";
        }
        if ($_ < 0) {
            croak "$_ is negative";
        }
    }
}

# click through rate (percentage)

sub ctr
{
    my ($clicks, $views) = @_;
    if ($views) {
        validate ($clicks, $views);
        return ($clicks / $views) * 100;
    }
    else {
        return undef;
    }
}

# cost per click

sub cpc
{
    my ($earnings, $clicks) = @_;
    if ($clicks) {
        validate ($earnings, $clicks);
        return $earnings / $clicks;
    }
    else {
        return undef;
    }
}

# revenue per mille

sub rpm
{
    my ($earnings, $views) = @_;
    if ($views) {
        validate ($earnings, $views);
        return ($earnings / $views) * 1000;
    }
}

sub add
{
    my ($cols, $this_period) = @_;
    # This contains the number of days.
    $this_period->[days_col]++;
    for (1..n_columns - 1) {
        if ($cols->[$_]) {
            $this_period->[$_] += $cols->[$_];
        }
    }
}

1;
