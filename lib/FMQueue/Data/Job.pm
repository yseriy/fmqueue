package FMQueue::Data::Job;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ( $self, $task_factory, $coder, $generator ) = @_;

    $self->{id}      = '';
    $self->{user_id} = '';
    $self->{size}    = 0;
    $self->{tasks}   = [];
    $self->{message} = undef;

    $self->{coder}   = $coder;
    $self->{generator} = $generator;
    $self->{task_factory} = $task_factory;

    return $self;
}

sub from_message {
    my ( $self, $message ) = @_;

    $self->{message} = $message;
    $self->from_string($message->to_string);

    return $self;
}

sub from_string {
    my ( $self, $string ) = @_;

    my $job = $self->{coder}->decode($string);

    $self->{id}      = $job->{id} || $self->{generator}->id;
    $self->{user_id} = $job->{user_id};
    $self->{size}    = scalar @{$job->{tasks}};

    for ( my $step = 1 ; $step <= $self->{size} ; $step++ ) {
        my $task = $self->{task_factory}->task;

        $task->from_hashref($job->{tasks}->[$step - 1]);

        $task->step($step);
        $task->job_size($self->{size});

        $task->job_id($self->{id});
        $task->id($self->{generator}->id);

        push @{$self->{tasks}}, $task;
    }

    return $self;
}

sub message {
    my ( $self, $message ) = @_;

    $self->{message} = $message if defined $message;

    return $self->{message};
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

sub size {
    my ($self) = @_;

    return $self->{size};
}

1;
