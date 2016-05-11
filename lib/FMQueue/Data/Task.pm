package FMQueue::Data::Task;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {};

    $self->{keys} = [qw{id task_id address data result}];

    return bless $self, $class;
}

sub coder {
    my ( $self, $coder ) = @_;

    $self->{coder} = $coder if defined $coder;

    return $self;
}

sub from_message {
    my ( $self, $message ) = @_;

    $self->from_string($message->to_string);

    return $self;
}

sub from_string {
    my ( $self, $string ) = @_;

    $self->from_hashref( $self->{coder}->decode($string) );

    return $self;
}

sub from_hashref {
    my ( $self, $hashref ) = @_;

    foreach my $key (@{$self->{keys}}) {
        $self->{$key} = $hashref->{$key};
    }

    return $self;
}

sub to_string {
    my ($self) = @_;

    my $tasks = {};

    foreach my $key (@{$self->{keys}}) {
        $tasks->{$key} = $self->{$key};
    }

    return $self->{coder}->encode($tasks);
}

sub seq_id {
    my ( $self, $seq_id ) = @_;

    $self->{id} = $seq_id if $seq_id;

    return $self->{id};
}

sub task_id {
    my ( $self, $task_id ) = @_;

    $self->{task_id} = $task_id if $task_id;

    return $self->{task_id};
}

sub address {
    my ($self) = @_;

    return $self->{address};
}

sub user_id {
    my ($self) = @_;

    return $self->{user_id};
}

sub result {
    my ($self) = @_;

    return $self->{result};
}

1;
