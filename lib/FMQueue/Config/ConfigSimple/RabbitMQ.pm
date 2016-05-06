package FMQueue::Config::ConfigSimple::RabbitMQ;

use strict;
use warnings;

use Config::Simple;

sub new {
    my ( $class, $config_path ) = @_;

    my $self = {};

    $self->{config_path}   = $config_path || 'etc/fmqueue.conf';
    $self->{mq_block_name} = 'transport';

    $self->{config} = Config::Simple->new($self->{config_path})
        or die "Can't find <$self->{config_path}> config file";

    return bless $self, $class;
}

sub parameters {
    my ($self) = @_;

    my $parameters = {};
    my $block = $self->{config}->param( -block=>$self->{mq_block_name} );

    if ( ! scalar keys %{$block} ) {
        die "Can't find <$self->{mq_block_name}> "
            . "block in <$self->{config_path}> file";
    }

    $parameters->{hostname} = delete $block->{hostname};
    $parameters->{queue}    = delete $block->{queue};
    $parameters->{option}   = $block;

    return $parameters;
}

1;
