package FMQueue::Log::Log4Perl;

use strict;
use warnings;

use Log::Log4perl;

sub new {
    my ( $class, $config ) = @_;

    my $self = {};

    $self->{config} = $config->parameters->{config_path} || 'etc/log.conf';

    Log::Log4perl::init($self->{config});
    $self->{log} = Log::Log4perl->get_logger;

    return bless $self, $class;
}

sub get_logger {
    my ($self) = @_;

    return $self->{log};
}

1;