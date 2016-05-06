package FMQueue::Data::Sequence;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {};

    $self->{tasks} = [];

    return bless $self, $class;
}



1;
