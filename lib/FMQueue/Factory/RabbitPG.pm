package FMQueue::Factory::RabbitPG;

use strict;
use warnings;

use FMQueue::Log::Log4Perl;
use FMQueue::Config::ConfigSimple::RabbitMQ;
use FMQueue::Config::ConfigSimple::DB;
use FMQueue::Config::ConfigSimple::Log4Perl;
use FMQueue::Transport::Worker::RabbitMQ;
use FMQueue::Transport::Client::RabbitMQ;
use FMQueue::Storage::PG;
use FMQueue::Signal::Semaphore;
use FMQueue::Utils::Daemonize;

sub new {
    my ( $class, $config ) = @_;

    my $self = {};

    $self->{config} = $config || '';

    return bless $self, $class;
}

sub log {
    my ($self) = @_;

    return FMQueue::Log::Log4Perl->new(
        FMQueue::Config::ConfigSimple::Log4Perl->new($self->{config})
    );
}

sub worker {
    my ($self) = @_;

    return FMQueue::Transport::Worker::RabbitMQ->new(
        FMQueue::Config::ConfigSimple::RabbitMQ->new($self->{config})
    );
}

sub client {
    my ($self) = @_;

    return FMQueue::Transport::Client::RabbitMQ->new( 
        FMQueue::Config::ConfigSimple::RabbitMQ->new($self->{config})
    );
}

sub storage {
    my ($self) = @_;

    return FMQueue::Storage::PG->new(
        FMQueue::Config::ConfigSimple::DB->new($self->{config})
    );
}

sub signal {
    return FMQueue::Signal::Semaphore->new;
}

sub daemon {
    return FMQueue::Utils::Daemonize->new;
}

1;
