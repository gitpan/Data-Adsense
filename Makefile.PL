use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pm = 'lib/Data/Adsense.pm';
my $pod = 'lib/Data/Adsense.pod';
my $repo = 'https://github.com/benkasminbullock/Data-Adsense';

WriteMakefile (
    NAME => 'Data::Adsense',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pod,
    AUTHOR => 'Ben Bullock <bkb@cpan.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
        'Date::Calc' => 0,
        'DateTime' => 0,
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => "$repo/issues",
        },
    },
    EXE_FILES => [
        'script/adstrapolate',
    ],
);
