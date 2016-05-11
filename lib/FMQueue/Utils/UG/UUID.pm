package FMQueue::Utils::UG::UUID;

use strict;
use warnings;

use Data::UUID;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ($self) = @_;

    $self->{ug} = Data::UUID->new;

    return $self;
}

sub id {
    my ($self) = @_;

    return lc $self->{ug}->create_str;
}

1;
