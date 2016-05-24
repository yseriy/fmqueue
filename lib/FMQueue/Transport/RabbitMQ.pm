package FMQueue::Transport::RabbitMQ;

use strict;
use warnings;

use Net::AMQP::RabbitMQ;

sub new {
    my ( $class, @params ) = @_;

    my $self = bless {
        hostname     => '',
        options      => undef,
        qos_options  => undef,
        channel      => 1,
        timeout      => 0,
        consumer_tag => '',
        factory      => undef,
        mq           => undef,
    }, $class;

    $self->init(@params);

    return $self;
}

sub init {
    my ( $self, $connect, $factory ) = @_;

    if ( defined $connect ) {
        $self->{hostname}    = $connect->hostname;
        $self->{options}     = $connect->options;
        $self->{qos_options} = $connect->qos;
    }

    $self->{factory} = $factory if defined $factory;
    $self->{mq} = Net::AMQP::RabbitMQ->new;
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

sub listen_queue {
    my ( $self, $queue ) = @_;

    $self->{mq}->queue_declare(
        $self->{channel},
        $queue->name,
        $queue->connect_options
    );

    $self->{mq}->consume(
        $self->{channel},
        $queue->name,
        $queue->listen_options
    );
}

sub receive_job {
    my ($self) = @_;

    my $message = $self->{factory}->message->from_hashref(
        $self->{mq}->recv($self->{timeout})
    );

    return $self->{factory}->job->from_message($message);
}

sub send_job_id {
    my ( $self, $job ) = @_;

    $self->{mq}->publish(
        $self->{channel},
        $job->message->properties->{reply_to},
        $job->id,
        {},
        { correlation_id => $job->message->properties->{correlation_id} }
    );
}

sub receive_task {
    my ($self) = @_;

    my $message = $self->{factory}->message->from_hashref(
        $self->{mq}->recv($self->{timeout})
    );

    return $self->{factory}->task->from_message($message);
}

sub send_task {
    my ( $self, $queue, $task ) = @_;

    $self->{mq}->queue_declare(
        $self->{channel},
        $queue->name,
        $queue->connect_options
    );

    $self->{mq}->publish(
        $self->{channel},
        $queue->name,
        $task->to_string,
        {},
        {}
    );
}

sub ack {
    my ( $self, $message ) = @_;

    $self->{mq}->ack( $self->{channel}, $message->info->{delivery_tag} );
}

1;
