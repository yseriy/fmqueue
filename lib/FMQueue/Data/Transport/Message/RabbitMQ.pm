package FMQueue::Data::Transport::Message::RabbitMQ;

use strict;
use warnings;

sub new {
    my ( $class, $raw_message ) = @_;

    my $self = {};

    if ( defined $raw_message ) {
        $self->{body} = delete $raw_message->{body};
        $self->{properties} = delete $raw_message->{props};
        $self->{info} = $raw_message;
        $self->{send_options} = {};
    }
    else {
        $self->{body} = {};
        $self->{properties} = {};
        $self->{info} = {};
        $self->{send_options} = {};
    }

    return bless $self, $class;
}

sub body {
    my ( $self, $body ) = @_;

    $self->{body} = $body if defined $body;

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
