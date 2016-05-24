package FMQueue::Data::Connect::Params::PG;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = bless {
        dsn  => '',
        user => '',
        pass => '',
    }, $class;

    return $self;
}

sub dsn {
    my ( $self, $dsn ) = @_;

    $self->{dsn} = $dsn if defined $dsn;

    return $self->{dsn};
}

sub user {
    my ( $self, $user ) = @_;

    $self->{user} = $user if defined $user;

    return $self->{user};
}

sub pass {
    my ( $self, $pass ) = @_;

    $self->{pass} = $pass if defined $pass;

    return $self->{pass};
}

1;
