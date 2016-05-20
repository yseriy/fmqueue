use strict;
use warnings;

use Data::Dumper;
use FMQueue::Utils::Config::ConfigGeneral;

my $conf = FMQueue::Utils::Config::ConfigGeneral->new->init(
    '/home/yseriy/project/FMQueue/current/etc/dispatcher_1.conf'
);
my $c = $conf->log_path;

print Dumper($c);
