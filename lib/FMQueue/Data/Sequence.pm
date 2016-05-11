package FMQueue::Data::Sequence;

use strict;
use warnings;

sub new {
    my ( $class, $task_factory, $coder, $generator ) = @_;

    my $self = {};

    $self->{id}      = '';
    $self->{user_id} = '';
    $self->{tasks}   = [];
    $self->{coder}   = $coder;
    $self->{generator} = $generator;
    $self->{task_factory} = $task_factory;

    return bless $self, $class;
}

sub from_message {
    my ( $self, $message ) = @_;

    $self->from_string($message->to_string);

    return $self;
}

sub from_string {
    my ( $self, $string ) = @_;

    my $sequence = $self->{coder}->decode($string);

    $self->{id} = $sequence->{id} || $self->{generator}->id;
    $self->{user_id} = $sequence->{user_id};

    foreach my $hashref (@{$sequence->{tasks}}) {
        my $task = $self->{task_factory}->task;

        $task->coder($self->{coder});
        $task->from_hashref($hashref);

        $task->seq_id($self->{id});
        $task->task_id($self->{generator}->id);

        push @{$self->{tasks}}, $task;
    }

    return $self;
}

sub id {
    my ($self) = @_;

    return $self->{id};
}

sub user_id {
    my ($self) = @_;

    return $self->{user_id};
}

sub tasks {
    my ($self) = @_;

    return $self->{tasks};
}

1;
