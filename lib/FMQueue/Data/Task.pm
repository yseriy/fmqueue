package FMQueue::Data::Task;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {};

    $self->{coder}   = '';
    $self->{seq_id}  = '';
    $self->{task_id} = '';
    $self->{address} = '';
    $self->{user_id} = '';
    $self->{data}    = {};
    $self->{result}  = {};

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

    $self->{seq_id}  = $hashref->{id}      || '';
    $self->{task_id} = $hashref->{task_id} || '';
    $self->{address} = $hashref->{address} || '';
    $self->{user_id} = $hashref->{user_id} || '';
    $self->{data}    = $hashref->{data};
    $self->{result}  = $hashref->{result};

    return $self;
}

sub to_string {
    my ($self) = @_;

    return $self->{coder}->encode($self);
}

sub seq_id {
    my ($self) = @_;

    return $self->{seq_id};
}

sub task_id {
    my ($self) = @_;

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
