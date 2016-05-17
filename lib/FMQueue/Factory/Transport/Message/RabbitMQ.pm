package FMQueue::Factory::Transport::Message::RabbitMQ;

use strict;
use warnings;

use FMQueue::Data::Transport::Message::RabbitMQ;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub message {
    my ($self) = @_;

    return FMQueue::Data::Transport::Message::RabbitMQ->new;
}

1;
