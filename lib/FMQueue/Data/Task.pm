package FMQueue::Data::Task;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ($self) = @_;

    $self->{keys} = [qw{id seq_id address step seq_size data result}];

    return $self;
}

sub coder {
    my ( $self, $coder ) = @_;

    $self->{coder} = $coder if defined $coder;

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

sub id {
    my ( $self, $id ) = @_;

    $self->{id} = $id if $id;

    return $self->{id};
}

sub seq_id {
    my ( $self, $seq_id ) = @_;

    $self->{seq_id} = $seq_id if $seq_id;

    return $self->{seq_id};
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

sub seq_size {
    my ( $self, $seq_size ) = @_;

    $self->{seq_size} = $seq_size if $seq_size;

    return $self->{seq_size};
}

sub result {
    my ($self) = @_;

    return $self->{result};
}

sub is_last_task {
    my ($self) = @_;

    return ( $self->{seq_size} - $self->{step} ) ? 0 : 1;
}

sub is_status_error {
    my ($self) = @_;

    return $self->{result}->{rc} ? 1 : 0;
}

1;
