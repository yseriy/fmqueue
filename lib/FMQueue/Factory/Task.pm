package FMQueue::Factory::Task;

use strict;
use warnings;

use FMQueue::Data::Task;

sub new {
    my($class) = @_;

    return bless {}, $class;
}

sub task {
    my ($self) = @_;

    return FMQueue::Data::Task->new->init;
}

1;
