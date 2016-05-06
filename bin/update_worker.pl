use strict;
use warnings;

use JSON;
use FMQueue::Factory::RabbitPG;

my $config_path = '/usr/local/fmqueue/etc/update_worker.conf';
my $factory = FMQueue::Factory::RabbitPG->new($config_path);

my $log = $factory->log;
my $storage = $factory->storage;
my $worker  = $factory->worker;
my $daemon  = $factory->daemon;

my $logger = $log->get_logger;

$daemon->start;

eval { $storage->connect };
if ( my $error = $@ ) {
    $logger->logdie("Connect to storage - Error: <$error>, Exit");
}
$logger->info("Connect to storage - OK");

eval{ $worker->connect };
if ( my $error = $@ ) {
    $logger->logdie("Connect to worker - Error: <$error>, Exit");
}
$logger->info("Connect to worker - OK");

while (1) {

    my $body = eval { $worker->receive };
    if ( my $error = $@ ) {
        $logger->logdie("Receive message - Error: <$error>, Exit");
    }
    else {
        $logger->info("Receive message - OK. Body: $body");
    }

    my $message = eval { decode_json $body };
    if ( my $error = $@ ) {
        $logger->error("Decode from json - Error: <$error>, Body: $body");
        next;
    }
    else {
        $logger->info("Decode from json - OK, Body: $body");
    }

    if ( ! $message->{id} ) {
        $logger->error("Empty id. Body: $body");
        next;
    }

    if ( ! $message->{task_id} ) {
        $logger->error("Empty task_id. Body: $body");
        next;
    }

    $message->{result}->{text} = '' if ! $message->{result}->{text};
    
    my $id = eval { $storage->update_transaction(
        $message->{id},
        $message->{task_id},
        $message->{result}
    )};
    if ( my $error = $@ ) {
        $logger->error("Update transaction - Error: <$error>, ",
            "id = $message->{id}, task_id = $message->{task_id}");
    }
    else {
        $logger->info("Update transaction - OK, id = $message->{id} ",
            "task_id = $message->{task_id}");
    }
}
