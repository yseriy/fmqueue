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

sub hostname {
    my ( $self, $hostname ) = @_;

    $self->{hostname} = $hostname if $hostname;

    return $self;
}

sub options {
    my ( $self, $options ) = @_;

    $self->{options} = $options if ref $options eq "HASH";

    return $self;
}

sub qos {
    my ( $self, $qos_options ) = @_;

    $self->{qos_options} = $qos_options if ref $qos_options eq "HASH";

    return $self;
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

sub create_queue {
    my ( $self, $queue ) = @_;

    $self->{mq}->queue_declare(
        $self->{channel},
        $queue->name,
        $queue->connect_options
    );
}

sub delete_queue {
    my ( $self, $queue ) = @_;

    $self->{mq}->queue_delete(
        $self->{channel},
        $queue->name,
        $queue->disconnect_options
    );
}

sub listen_queue {
    my ( $self, $queue ) = @_;

    $self->{consumer_tag} = $self->{mq}->consume(
        $self->{channel},
        $queue->name,
        $queue->listen_options
    );
}

sub cancel_listen_queue {
    my ( $self, $queue ) = @_;

    $self->{mq}->cancel( $self->{channel}, $self->{consumer_tag} );
}

sub send {
    my ( $self, $queue, $message ) = @_;

    $self->{mq}->publish(
        $self->{channel},
        $queue->name,
        $message->to_string,
        $message->send_options,
        $message->properties
    );
}

sub receive {
    my ($self) = @_;

    return $self->{message_factory}->message->from_hashref(
        $self->{mq}->recv($self->{timeout})
    );
}

sub ack {
    my ( $self, $message ) = @_;

    $self->{mq}->ack( $self->{channel}, $message->info->{delivery_tag} );
}

1;
