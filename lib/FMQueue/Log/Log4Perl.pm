package FMQueue::Log::Log4Perl;

use strict;
use warnings;

use Log::Log4perl;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ( $self, $config ) = @_;

    Log::Log4perl::init($config->parameters->{config_path});
    $self->{log} = Log::Log4perl->get_logger;

    return $self;
}

sub logger {
    my ($self) = @_;

    return $self->{log};
}

1;
