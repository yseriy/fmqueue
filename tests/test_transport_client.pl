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

use Data::UUID;
use Net::AMQP::RabbitMQ;

my $ug = Data::UUID->new;
my $mq = Net::AMQP::RabbitMQ->new;

my $hostname = 'tst202-queue00.vm.rcdn.ru';
my $options  = {user => 'fmqueue', password => 'qwerty1'};
my $timeout  = 0;
my $channel  = 1;
my $queue    = 'r1';
my $body     = $string;#'test_command';
my $correlation_id = $ug->create_str;

$mq->connect( $hostname, $options );
$mq->channel_open($channel);

# my $message = {
#      id      => '6d5aa728-0d4b-11e6-b37b-5a5a47e7b3b7',
#      task_id => '6d5ab420-0d4b-11e6-b37b-5a5a47e7b3b7',
#      result  => {
#          rc   => 0,
#          text => 'success',
#      },
# };

# my $message = {
#     account => 'user1',
#     address => 'host1',
#     data => {
#         command => 'test_command',
#         args    => {
#             a1 => 1,
#             a2 => 2,
#         },
#     },
# };
#
#$body = encode_json $message;
my $callback_queue = $mq->queue_declare( $channel, '', { exclusive => 1 } );

$mq->publish(
    $channel,
    $queue,
    $body,
    {},
    { correlation_id => $correlation_id, reply_to => $callback_queue }
);

print "Send Request\n";

$mq->consume( $channel, $callback_queue );

# print "Waiting for response. To exit press CTRL+C\n";

while ( my $msg = $mq->recv($timeout) ) {
     if ( $correlation_id eq $msg->{props}->{correlation_id} ) {
         print "$msg->{body} ($msg->{routing_key})\n";
         last;
     }
}

$mq->disconnect;


# my $message_factory = FMQueue::Factory::Transport::Message::RabbitMQ->new;
# my $job_factory  = FMQueue::Factory::Job->new;
# my $task_factory = FMQueue::Factory::Task->new;
#
# my $queue = FMQueue::Data::Transport::Queue::RabbitMQ->new->init;
# my $task  = $task_factory->task->from_hashref($t->[0]);
#
# my $transport = FMQueue::Transport::RabbitMQ->new->init(
#     'tst202-queue00.vm.rcdn.ru',
#     { user => 'fmqueue', password => 'qwerty1' },
#     { prefetch_count => 1 }
# );
# $transport->message_factory($message_factory);
# $transport->job_factory($job_factory);
# $transport->task_factory($task_factory);
#
# $queue->name('r1');
#
# $transport->connect;
# $transport->listen_queue($queue);
# my $job = $transport->receive_job;
#
# print Dumper($job);
