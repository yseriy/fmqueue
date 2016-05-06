package FMQueue::Transport::Worker::RabbitMQ;

use strict;
use warnings;

use Net::AMQP::RabbitMQ;

sub new {
    my ( $class, $config ) = @_;

    my $self = {};

    $self->{hostname} = '';
    $self->{options}  = '';
    $self->{queue}    = '';
    $self->{channel}  = 1;
    $self->{reply_to} = '';
    $self->{correlation_id} = '';
    $self->{config} = $config;

    return bless $self, $class;
}

sub read_config {
    my ($self) = @_;

    my $parameters = $self->{config}->parameters;

    $self->{hostname} = $parameters->{hostname} || '';
    $self->{options}  = $parameters->{option}   || '';
    $self->{queue}    = $parameters->{queue}    || '';
}

sub connect {
    my ($self) = @_;

    $self->read_config;

    $self->{mq} = Net::AMQP::RabbitMQ->new;

    $self->{mq}->connect( $self->{hostname}, $self->{options} );
    $self->{mq}->channel_open($self->{channel});
    $self->{mq}->basic_qos( $self->{channel}, { prefetch_count => 1 } );

    $self->{mq}->queue_declare(
        $self->{channel},
        $self->{queue},
        { durable => 1, auto_delete => 0 }
    );
    $self->{mq}->consume( $self->{channel}, $self->{queue} );    
}

sub disconnect {
    my ($self) = @_;

    $self->{mq}->disconnect;
}

sub reconnect {
    my ($self) = @_;

    $self->connect if ! $self->{mq}->is_connected;
}

sub set_queue {
    my ( $self, $queue ) = @_;

    $self->{queue} = $queue;
}

sub receive {
    my ($self) = @_;

    my $msg = $self->{mq}->recv;

    $self->{reply_to} = $msg->{props}->{reply_to} || '';
    $self->{correlation_id} = $msg->{props}->{correlation_id} || '';

    return $msg->{body};
}

sub send_ack {
    my ( $self, $body ) = @_;

    $self->{mq}->publish(
        $self->{channel},
        $self->{reply_to},
        $body,
        {},
        { correlation_id => $self->{correlation_id} }
    );
}

1;
