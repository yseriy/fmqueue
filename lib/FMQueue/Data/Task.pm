package FMQueue::Data::Task;

use strict;
use warnings;

sub new {
    my ( $class, $coder ) = @_;

    my $self = {};

    $self->{coder} = $coder;

    $self->{task_id} = '';
    $self->{address} = '';
    $self->{user_id} = '';
    $self->{data}    = {};
    $self->{result}  = {};

    return bless $self, $class;
}

sub from_string {
    my ( $self, $string ) = @_;

    my $task = $self->{coder}->decode($string);

    $self->{task_id} = $task->{task_id} || '';
    $self->{address} = $task->{address} || '';
    $self->{user_id} = $task->{user_id} || '';
    $self->{data}    = $task->{data};
    $self->{result}  = $task->{result};
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
