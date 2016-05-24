package FMQueue::Factory::Data;

use strict;
use warnings;

use FMQueue::Data::Transport::Message::RabbitMQ;
use FMQueue::Data::Task;
use FMQueue::Data::Job;
use FMQueue::Utils::Serializer::JSON;
use FMQueue::Utils::UG::UUID;

sub new {
    my ($class) = @_;

    my $self = bless {
    }, $class;

    return $self;
}

sub message {
    my ($self) = @_;

    return FMQueue::Data::Transport::Message::RabbitMQ->new;
}

sub task {
    my ($self) = @_;

    return FMQueue::Data::Task->new->init->coder(
        FMQueue::Utils::Serializer::JSON->new->init
    );
}

sub job {
    my ($self) = @_;

    return FMQueue::Data::Job->new->init(
        $self->task,
        FMQueue::Utils::Serializer::JSON->new->init,
        FMQueue::Utils::UG::UUID->new->init
    );
}

1;
