package FMQueue::Data::Transport::Queue::RabbitMQ;

use strict;
use warnings;

sub new {
    my ( $class, $name ) = @_;

    my $self = {};

    $self->{name} = $name || '';
    $self->{connect_options} = {};
    $self->{disconnect_options} = {};
    $self->{listen_options} = {};

    return bless $self, $class;
}

sub name {
    my ( $self, $name ) = @_;

    $self->{name} = $name if $name;

    return $self->{name};
}

sub connect_options {
    my ( $self, $connect_options ) = @_;

    $self->{connect_options} = $connect_options if defined $connect_options;

    return $self->{connect_options};
}

sub disconnect_options {
    my ( $self, $disconnect_options ) = @_;

    $self->{disconnect_options} = $disconnect_options if defined $disconnect_options;

    return $self->{disconnect_options};
}

sub listen_options {
    my ( $self, $listen_options ) = @_;

    $self->{listen_options} = $listen_options if defined $listen_options;

    return $self->{listen_options};
}

1;
