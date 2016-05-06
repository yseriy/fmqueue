package FMQueue::Transport::Client::RabbitMQ;

use strict;
use warnings;

use Data::UUID;
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
    $self->{timeout} = 0;

    $self->{ug} = Data::UUID->new;
    $self->{mq} = Net::AMQP::RabbitMQ->new;

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

    $self->{mq}->connect( $self->{hostname}, $self->{options} );
    $self->{mq}->channel_open($self->{channel});

    $self->{mq}->queue_declare(
        $self->{channel},
        $self->{queue},
        { durable => 1, auto_delete => 0 }
    );
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

    $self->{mq}->queue_declare(
        $self->{channel},
        $queue,
        { durable => 1, auto_delete => 0 }
    );
    $self->{queue} = $queue;
}

sub send {
    my ( $self, $body ) = @_;

    $body = $body || '';

    $self->{mq}->publish( $self->{channel}, $self->{queue}, $body);
}

sub sync_send {
    my ( $self, $body ) = @_;

    $body = $body || '';

    my $correlation_id = $self->{ug}->create_str;
    my $callback_queue = $self->{mq}->queue_declare(
        $self->{channel},
        '',
        { exclusive => 1 }
    );

    $self->{mq}->publish(
        $self->{channel},
        $self->{queue},
        $body,
        {},
        { correlation_id => $correlation_id, reply_to => $callback_queue }
    );

    $self->{mq}->consume( $self->{channel}, $callback_queue );

    my $responce;

    while ( my $msg = $self->{mq}->recv($self->{timeout}) ) {
        if ( $correlation_id eq $msg->{props}->{correlation_id} ) {
            $responce = $msg->{body};
            last;
        }
    }

    $self->{mq}->queue_delete(
        $self->{channel},
        $callback_queue,
        { if_unused => 0, if_empty => 0 }
    );

    return $responce;
}

1;
