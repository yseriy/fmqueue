package FMQueue::Factory::Job;

use strict;
use warnings;

use FMQueue::Data::Job;
use FMQueue::Factory::Task;
use FMQueue::Utils::Serializer::JSON;
use FMQueue::Utils::UG::UUID;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub job {
    my ($self) = @_;

    return FMQueue::Data::Job->new->init(
        FMQueue::Factory::Task->new,
        FMQueue::Utils::Serializer::JSON->new->init,
        FMQueue::Utils::UG::UUID->new->init
    );
}

1;
