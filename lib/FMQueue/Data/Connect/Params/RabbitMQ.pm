package FMQueue::Data::Connect::Params::RabbitMQ;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = bless {
        hostname => '',
        params   => undef,
        qos      => undef,
    }, $class;

    return $self;
}

sub hostname {
    my ( $self, $hostname ) = @_;

    $self->{hostname} = $hostname if defined $hostname;

    return $self->{hostname};
}

sub params {
    my ( $self, $params ) = @_;

    $self->{params} = $params if defined $params;

    return $self->{params};
}

sub qos {
    my ( $self, $qos ) = @_;

    $self->{qos} = $qos if defined $qos;

    return $self->{qos};
}

1;
