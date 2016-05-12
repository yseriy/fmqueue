package FMQueue::Data::Sequence;

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
    $self->{coder}   = $coder;
    $self->{generator} = $generator;
    $self->{task_factory} = $task_factory;

    return $self;
}

sub from_string {
    my ( $self, $string ) = @_;

    my $sequence = $self->{coder}->decode($string);

    $self->{id}      = $sequence->{id} || $self->{generator}->id;
    $self->{user_id} = $sequence->{user_id};
    $self->{size}    = scalar @{$sequence->{tasks}};

    for ( my $step = 1 ; $step <= $self->{size} ; $step++ ) {
        my $task = $self->{task_factory}->task;

        $task->coder($self->{coder});
        $task->from_hashref($sequence->{tasks}->[$step - 1]);

        $task->step($step);
        $task->seq_size($self->{size});

        $task->seq_id($self->{id});
        $task->id($self->{generator}->id);

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

sub size {
    my ($self) = @_;

    return $self->{size};
}

1;
