package FMQueue::Signal::Semaphore;

use strict;
use warnings;

use IPC::SysV qw{S_IRUSR S_IWUSR IPC_CREAT};
use IPC::Semaphore;

sub new {
    my ( $class, $config ) = @_;

    my $self = {};

    $self->{key} = 12345;
    $self->{first_semaphore}  = 0;
    $self->{semaphore_number} = 1;

    return bless $self, $class;
}

sub set_handler {
    my ($self) = @_;

    $self->{semaphore} = IPC::Semaphore->new(
        $self->{key},
        $self->{semaphore_number},
        S_IRUSR | S_IWUSR | IPC_CREAT
    );

    die "Semaphore trouble: $!" if ! $self->{semaphore};
}

sub send {
    my ($self) = @_;

    $self->{semaphore}->setval( $self->{first_semaphore}, 1 );
}

sub wait {
    my ($self) = @_;

    $self->{semaphore}->op( $self->{first_semaphore}, -1, 0 );
}

1;
