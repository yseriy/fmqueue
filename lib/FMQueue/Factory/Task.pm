package FMQueue::Factory::Task;

use strict;
use warnings;

use FMQueue::Data::Task;
use FMQueue::Utils::Serializer::JSON;

sub new {
    my($class) = @_;

    return bless {}, $class;
}

sub task {
    my ($self) = @_;

    return FMQueue::Data::Task->new->init->coder(
        FMQueue::Utils::Serializer::JSON->new->init
    );
}

1;
