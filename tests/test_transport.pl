use strict;
use warnings;

use JSON;
use Data::Dumper;

use FMQueue::Transport::RabbitMQ;
use FMQueue::Data::Transport::Queue::RabbitMQ;

use FMQueue::Factory::Data::Task;
use FMQueue::Factory::Data::Job;
use FMQueue::Factory::Data::Transport::Message::RabbitMQ;


my $t = [];

for ( my $i = 1 ; $i <= 10 ; $i++ ){
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

my $string = encode_json $sequence;

my $message_factory = FMQueue::Factory::Data::Transport::Message::RabbitMQ->new;
my $job_factory  = FMQueue::Factory::Data::Job->new;
my $task_factory = FMQueue::Factory::Data::Task->new;

my $queue = FMQueue::Data::Transport::Queue::RabbitMQ->new->init;
#my $task  = $task_factory->task->from_hashref($t->[0]);

my $transport = FMQueue::Transport::RabbitMQ->new->init(
    'tst202-queue00.vm.rcdn.ru',
    { user => 'fmqueue', password => 'qwerty1' },
    { prefetch_count => 1 }
);
$transport->message_factory($message_factory);
$transport->job_factory($job_factory);
$transport->task_factory($task_factory);

$queue->name('r1');

$transport->connect;
$transport->listen_queue($queue);
my $job = $transport->receive_job;

print Dumper($job);

$transport->send_job_id($job);
# my $task = $transport->receive_task;
# 
# print Dumper($task);
