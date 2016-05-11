package FMQueue::Utils::Serializer::JSON;

use strict;
use warnings;

use JSON;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ($self) = @_;

    $self->{coder} = JSON->new;

    return $self;
}

sub decode {
    my ( $self, $string ) = @_;

    return $self->{coder}->decode($string);
}

sub encode {
    my ( $self, $scalar ) = @_;

    return $self->{coder}->encode($scalar);
}

1;
