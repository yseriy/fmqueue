package FMQueue::Factory::Transport::Queue::RabbitMQ;

use strict;
use warnings;

use FMQueue::Utils::Config::ConfigGeneral;
use FMQueue::Data::Transport::Queue::RabbitMQ;

sub new {
    my ( $class, $conifg_path ) = @_;

    my $self = {};

    $self->{config} = {};

    my $config = FMQueue::Utils::Config::ConfigGeneral->new($config_path);
    my %config = $config->parameters;

    $self->{config} = \%config;

    return bless $self, $class;
}

sub queue {
    my ($self) = @_;

    my $queue = FMQueue::Data::Transport::Queue::RabbitMQ->new;

    $queue->connect_options(
        $self->{config}->{transport}->{queue}->{connect_options}
    );

    return $queue;
}

1;
