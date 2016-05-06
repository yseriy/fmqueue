package FMQueue::Config::ConfigSimple::DB;

use strict;
use warnings;

use Config::Simple;

sub new {
    my ( $class, $config ) = @_;

    my $self = {};

    $self->{config_path} = $config || 'etc/fmqueue.conf';
    $self->{block_name}  = 'db';

    $self->{config} = Config::Simple->new($self->{config_path})
        or die "Can't find <$self->{config_path}> config file";

    return bless $self, $class;
}

sub parameters {
    my ($self) = @_;

    my $block = $self->{config}->param( -block=>$self->{block_name} );

    if ( ! scalar keys %{$block} ) {
        die "Can't find <$self->{db_block_name}> "
            . "block in <$self->{config_path}> file";
    }

    return $block;
}

1;
