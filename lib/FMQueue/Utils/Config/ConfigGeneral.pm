package FMQueue::Utils::Config::ConfigGeneral;

use strict;
use warnings;

use Config::General;

sub new {
    my ( $class, $config_path ) = @_;

    die "Config path is empty" if ! $config_path;

    my $self = {};

    $self->{config} = Config::General->new($config_path);

    return bless $self, $class;
}

sub parameters {
    my ($self) = @_;

    my %config = $self->{config}->getall;

    return \%config;
}

1;
