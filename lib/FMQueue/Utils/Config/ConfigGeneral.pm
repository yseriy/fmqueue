package FMQueue::Utils::Config::ConfigGeneral;

use strict;
use warnings;

use Config::General;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ( $self, $config_path ) = @_;

    die "Config path empty" if ! $config_path;

    my %config = Config::General->new($config_path)->getall;

    $self->{config} = \%config;

    return $self;
}

sub log_path {
    my ($self) = @_;

    return $self->{config}->{log}->{path};
}

1;
