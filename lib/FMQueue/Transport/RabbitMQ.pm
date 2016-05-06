package FMQueue::Transport::RabbitMQ;

use strict;
use warnings;

use Net::AMQP::RabbitMQ;

sub new {
    my ( $class, $message_factory ) = @_;

    my $self = {};

    $self->{hostname}    = '';
    $self->{options}     = {};
    $self->{qos_options} = {};

    $self->{channel} = 1;
    $self->{timeout} = 0;
    $self->{consumer_tag} = '';

    $self->{message_factory} = $message_factory;
    $self->{mq} = Net::AMQP::RabbitMQ->new;

    return bless $self, $class;
}

sub connect_parameters {
    my ( $self, $hostname, $options, $qos_options ) = @_;

    $self->{hostname}    = $hostname    || '';
    $self->{options}     = $options     || {};
    $self->{qos_options} = $qos_options || {};
}

sub connect {
    my ($self) = @_;

    $self->{mq}->connect( $self->{hostname}, $self->{options} );
    $self->{mq}->channel_open($self->{channel});
    $self->{mq}->basic_qos( $self->{channel}, $self->{qos_options} );
}

sub disconnect {
    my ($self) = @_;

    $self->{mq}->disconnect;
}

sub reconnect {
    my ($self) = @_;

    $self->connect if ! $self->{mq}->is_connected;
}

sub connect_queue {
    my ( $self, $queue ) = @_;

    $self->{mq}->queue_declare(
        $self->{channel},
        $queue->name,
        $queue->connect_options
    );
}

sub disconnect_queue {
    my ( $self, $queue ) = @_;

    queue_delete( $self->{channel}, $queue, $queue->disconnect_options );
}

sub listen_queue {
    my ( $self, $queue ) = @_;

    $self->{consumer_tag} = $self->{mq}->consume(
        $self->{channel},
        $queue->name,
        $queue->listen_options
    );
}

sub cancel_listen {
    my ( $self, $queue ) = @_;

    $self->{mq}->cancel( $self->{channel}, $self->{consumer_tag} );
}

sub send {
    my ( $self, $queue, $message ) = @_;

    $self->{mq}->publish(
        $self->{channel},
        $queue->name,
        $message->body,
        $message->send_options,
        $message->properties
    );
}

sub receive {
    my ($self) = @_;

    return $self->{message_factory}->message(
        $self->{mq}->recv($self->{timeout})
    );
}

1;
