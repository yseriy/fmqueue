use strict;
use warnings;

use JSON;
use Data::Dumper;

use FMQueue::Data::Job;
use FMQueue::Storage::PG;

use FMQueue::Factory::Task;
use FMQueue::Utils::Serializer::JSON;
use FMQueue::Utils::UG::UUID;

my $t = [];

for ( my $i = 1 ; $i < 10 ; $i++ ){
    push @{$t}, {
        id  => '',
        job_id => '',
        address => 'test_host' . $i,
        data => {
            command => 'command' . $i,
            args => {
                a1 => 1,
                a2 => 2,
            },
        },
        result => {
            rc   => 1,
            text => '',
        },
    };
}

my $sequence = {
    id      => '',
    user_id => 'test_user',
    tasks   => $t,
};

my $r_t = {
    id     => '8cdd494e-1b5f-11e6-bea9-2aefa9235a8e',
    seq_id => '8cdd40f2-1b5f-11e6-bea9-2aefa9235a8e',
    step     => 1,
    seq_size => 9,
    result => {
        rc   => 0,
        text => 'complete',
    },
};

#print encode_json $sequence;
#print "\n";

my $job = FMQueue::Data::Job->new->init(
    FMQueue::Factory::Task->new,
    FMQueue::Utils::Serializer::JSON->new->init,
    FMQueue::Utils::UG::UUID->new->init
);

$job->from_string(encode_json $sequence);

#print Dumper($sequence);

my $tasks = $job->tasks;

print Dumper($tasks);

my $dsn  = 'dbi:Pg:dbname=scheduler;host=localhost;port=3102';
my $user = 'scheduler';
my $pass = 'qwerty';

my $storage = FMQueue::Storage::PG->new->init(
    $dsn,
    $user,
    $pass
)->task_factory(
    FMQueue::Factory::Task->new
);

$storage->connect;

#$storage->submit_job($seq);
#my $tsks = $storage->get_ready_tasks;
#print Dumper($tsks);
# $storage->processing_task($tsks->[0]);
# $storage->processing_task($tsks->[1]);

# my $task = $task_factory->task->from_hashref($r_t);
# print Dumper($task);
# $storage->set_task_result($task);
