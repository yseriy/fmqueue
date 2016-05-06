package FMQueue::Factory::Transport::RabbitMQ;

use strict;
use warnings;

use FMQueue::Utils::Config::ConfigGeneral;
use FMQueue::Transport::RabbitMQ;

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

sub transport {
    my ( $self, $message_factory ) = @_;

    my $transport = FMQueue::Transport::RabbitMQ->new($message_factory);

    $transport->connect_parameters(
        $self->{config}->{transport}->{connect}->{hostname},
        $self->{config}->{transport}->{connect}->{options},
        $self->{config}->{transport}->{connect}->{qos}
    );

    return $transport;
}

1;
