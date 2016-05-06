package FMQueue::Factory::Transport::Message::RabbitMQ;

use strict;
use warnings;

use FMQueue::Data::Transport::Message::RabbitMQ;

sub new {
    my ($class) = @_;

    my $self = {};

    return bless $self, $class;
}

sub message {
    my ( $self, $raw_message ) = @_;

    return FMQueue::Data::Transport::Message::RabbitMQ->new($raw_message);
}

1;
