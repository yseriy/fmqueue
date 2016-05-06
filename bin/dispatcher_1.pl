use strict;
use warnings;

use FMQueue::Factory::Transport::Message::RabbitMQ;
use FMQueue::Factory::Transport::RabbitMQ;

my $message_factory = FMQueue::Factory::Transport::Message::RabbitMQ->new;
my $transport_factory = FMQueue::Factory::Transport::RabbitMQ->new;

my $queue = $transport_factory->queue;
my $client = $transport_factory->transport($message_factory);
