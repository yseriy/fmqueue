package FMQueue::Factory::RabbitPG;

use strict;
use warnings;

use FMQueue::Utils::Config::ConfigGeneral;
use FMQueue::Factory::Data;
use FMQueue::Data::Connect::Params::PG;
use FMQueue::Data::Connect::Params::RabbitMQ;
use FMQueue::Transport::RabbitMQ;
use FMQueue::Storage::PG;
use FMQueue::Signal::Semaphore;
use FMQueue::Utils::Daemonize;

sub new {
    my ( $class, @params ) = @_;

    my $self = bless {
        config => '',
    }, $class;

    $self->init(@params);

    return $self;
}

sub init {
    my ( $self, $config_path ) = @_;

    $self->{config} = FMQueue::Utils::Config::ConfigGeneral->new($config_path);
}

sub transport {
    my ($self) = @_;

    my $connect = FMQueue::Data::Connect::Params::RabbitMQ->new;

    $connect->hostname($self->{config}->hostname);
    $connect->options($self->{config}->options);
    $connect->qos($self->{config}->qos);

    return FMQueue::Transport::RabbitMQ->new(
        $connect,
        FMQueue::Factory::Data->new
    );
}

sub storage {
    my ($self) = @_;

    my $connect = FMQueue::Data::Connect::Params::PG->new;

    $connect->dsn($self->{config}->dsn);
    $connect->user($self->{config}->user);
    $connect->pass($self->{config}->pass);

    return FMQueue::Storage::PG->new(
        $connect,
        FMQueue::Factory::Data->new
    );
}

sub signal {
    return FMQueue::Signal::Semaphore->new;
}

sub daemon {
    return FMQueue::Utils::Daemonize->new;
}

1;
