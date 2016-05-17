package FMQueue::Data::Task;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ($self) = @_;

    $self->{keys} = [qw{id job_id address step job_size data result}];

    $self->{message} = undef;

    return $self;
}

sub coder {
    my ( $self, $coder ) = @_;

    $self->{coder} = $coder if defined $coder;

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

    my $task = {};

    foreach my $key (@{$self->{keys}}) {
        $task->{$key} = $self->{$key};
    }

    return $self->{coder}->encode($task);
}

sub message {
    my ( $self, $message ) = @_;

    $self->{message} = $message if defined $message;

    return $self->{message};
}

sub id {
    my ( $self, $id ) = @_;

    $self->{id} = $id if $id;

    return $self->{id};
}

sub job_id {
    my ( $self, $job_id ) = @_;

    $self->{job_id} = $job_id if $job_id;

    return $self->{job_id};
}

sub address {
    my ($self) = @_;

    return $self->{address};
}

sub step {
    my ( $self, $step ) = @_;

    $self->{step} = $step if $step;

    return $self->{step};
}

sub job_size {
    my ( $self, $job_size ) = @_;

    $self->{job_size} = $job_size if $job_size;

    return $self->{job_size};
}

sub result {
    my ($self) = @_;

    return $self->{result};
}

sub is_last_task {
    my ($self) = @_;

    return ( $self->{job_size} - $self->{step} ) ? 0 : 1;
}

sub is_status_error {
    my ($self) = @_;

    return $self->{result}->{rc} ? 1 : 0;
}

1;
