package FMQueue::Utils::Daemonize;

use strict;
use warnings;

use POSIX qw{setsid};

sub new {
    my ($class)  = @_;

    my $self = {};

    return bless $self, $class;
}


sub start {
    my ($self) = @_;

    my $pid = fork();
    die "fork() failed: $!" if ! defined $pid;

    exit 0 if $pid;

    POSIX::setsid();
    $SIG{HUP} = "IGNORE";

    $pid = fork();
    die "fork() failed: $!" if ! defined $pid;

    exit 0 if $pid;

    chdir '/';
    umask 0;

    open STDIN,  '<', '/dev/null' or die "Can't open STDIN from /dev/null: [$!]\n";
    open STDOUT, '>', '/dev/null' or die "Can't open STDOUT to /dev/null: [$!]\n";
    open STDERR, '>&STDOUT'       or die "Can't open STDERR to STDOUT: [$!]\n";
}

1;