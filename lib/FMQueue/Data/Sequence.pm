package FMQueue::Data::Sequence;

use strict;
use warnings;

sub new {
    my ( $class, $coder ) = @_;

    my $self = {};

    $self->{id}    = '';
    $self->{tasks} = [];
    $self->{coder} = $coder;

    return bless $self, $class;
}

sub from_string {
    my ( $self, $string ) = @_;

    my $sequence = $coder->decode($string);

    $self->{id}    = $sequence->{id};
    $self->{tasks} = $sequence->{tasks};
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
