package FMQueue::Transport::RabbitMQ;

use strict;
use warnings;

use Net::AMQP::RabbitMQ;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ( $self, $hostname, $options, $qos ) = @_;

    $self->{hostname}    = $hostname || '';
    $self->{options}     = $options  || {};
    $self->{qos_options} = $qos || {};

    $self->{channel} = 1;
    $self->{timeout} = 0;
    $self->{consumer_tag} = '';

    $self->{message_factory} = '';
    $self->{job_factory}  = '';
    $self->{task_factory} = '';
    $self->{mq} = Net::AMQP::RabbitMQ->new;

    return $self;
}

sub message_factory {
    my ( $self, $message_factory ) = @_;

    $self->{message_factory} = $message_factory if defined $message_factory;

    return $self;
}

sub job_factory {
    my ( $self, $job_factory ) = @_;

    $self->{job_factory} = $job_factory if defined $job_factory;

    return $self;
}

sub task_factory {
    my ( $self, $task_factory ) = @_;

    $self->{task_factory} = $task_factory if defined $task_factory;

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

sub listen_queue {
    my ( $self, $queue ) = @_;

    $self->{consumer_tag} = $self->{mq}->consume(
        $self->{channel},
        $queue->name,
        $queue->listen_options
    );
}

sub receive_job {
    my ($self) = @_;

    my $message = $self->{message_factory}->message->from_hashref(
        $self->{mq}->recv($self->{timeout})
    );

    return $self->{job_factory}->job->from_message($message);
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

    my $message = $self->{message_factory}->message->from_hashref(
        $self->{mq}->recv($self->{timeout})
    );

    return $self->{task_factory}->task->from_message($message);
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
