package FMQueue::Data::Transport::Message::RabbitMQ;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ($self) = @_;

    $self->{body} = '';
    $self->{properties} = {};
    $self->{info} = {};
    $self->{send_options} = {};

    return $self;
}

sub from_hashref {
    my ( $self, $hashref ) = @_;

    $self->{body} = delete $hashref->{body} || '';
    $self->{properties} = delete $hashref->{props};
    $self->{info} = $hashref;

    return $self;
}

sub to_string {
    my ($self) = @_;

    return $self->{body};
}

sub properties {
    my ( $self, $properties ) = @_;

    $self->{properties} = $properties if defined $properties;

    return $self->{properties};
}

sub info {
    my ( $self, $info ) = @_;

    $self->{info} = $info if defined $info;

    return $self->{info};
}

sub send_options {
    my ( $self, $send_options ) = @_;

    $self->{send_options} = $send_options if defined $send_options;

    return $self->{send_options};
}

1;
