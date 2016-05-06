use strict;
use warnings;

use Data::Dumper;
use FMQueue::Utils::Config::ConfigGeneral;

my $conf = FMQueue::Utils::Config::ConfigGeneral->new(
    '/home/yseriy/project/FMQueue/current/etc/dispatcher_1.conf'
);
my $c = $conf->parameters;

print Dumper($c);

print $c->{transport}->{connect}->{hostname}, "\n";
