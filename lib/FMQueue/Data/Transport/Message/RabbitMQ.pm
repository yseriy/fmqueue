package FMQueue::Data::Transport::Message::RabbitMQ;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {};

    $self->{body} = '';
    $self->{properties} = {};
    $self->{info} = {};
    $self->{send_options} = {};

    return bless $self, $class;
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

sub load_task {
    my ( $self, $task ) = @_;

    $self->{body} = $task->to_string;
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
