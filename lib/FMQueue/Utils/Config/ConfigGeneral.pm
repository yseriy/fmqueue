package FMQueue::Utils::Config::ConfigGeneral;

use strict;
use warnings;

use Config::General;

sub new {
    my ( $class, @params ) = @_;

    my $self = bless {
        config => undef,
    }, $class;

    $self->init(@params)

    return $self;
}

sub init {
    my ( $self, $config_path ) = @_;

    die "Config path empty" if ! $config_path;

    my %config = Config::General->new($config_path)->getall;
    $self->{config} = \%config;
}

sub transport_hostname {
    my ($self) = @_;

    return $self->{config}->{transport}->{connect}->{hostname};
}

sub options {
    my ($self) = @_;

    return $self->{config}->{transport}->{connect}->{options};
}

sub qos {
    my ($self) = @_;

    return self->{config}->{transport}->{connect}->{qos};
}

sub log_path {
    my ($self) = @_;

    return $self->{config}->{log}->{path};
}

1;
