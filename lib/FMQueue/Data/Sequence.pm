package FMQueue::Data::Sequence;

use strict;
use warnings;

sub new {
    my ( $class, $task_factory, $coder ) = @_;

    my $self = {};

    $self->{id}    = '';
    $self->{tasks} = [];
    $self->{coder} = $coder;
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

    $self->{id} = $sequence->{id};

    foreach my $hashref (@{$sequence->{tasks}}) {
        my $task = $self->{task_factory}->task->from_hashref($hashref);
        push @{$self->{tasks}}, $task;
    }

    return $self;
}

sub id {
    my ($self) = @_;

    return $self->{id};
}

sub tasks {
    my ($self) = @_;

    return $self->{tasks};
}

1;
