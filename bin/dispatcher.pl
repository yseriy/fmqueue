use strict;
use warnings;

use JSON;
use FMQueue::Factory::RabbitPG;

my $config_path = '/usr/local/fmqueue/etc/dispatcher.conf';
my $factory = FMQueue::Factory::RabbitPG->new($config_path);

my $log = $factory->log;
my $storage = $factory->storage;
my $client  = $factory->client;
my $signal  = $factory->signal;
my $daemon  = $factory->daemon;

my $logger = $log->get_logger;

$daemon->start;

eval { $signal->set_handler };
if ( my $error = $@ ) {
    $logger->logdie("Set signal handler - Error: <$error>");
}
$logger->info("Set signal handler - OK");

eval { $storage->connect };
if ( my $error = $@ ) {
    $logger->logdie("Connect to storage - Error: <$error>");
}
$logger->info("Connect to storage - OK");

eval{ $client->connect };
if ( my $error = $@ ) {
    $logger->logdie("Connect to client - Error: <$error>");
}
$logger->info("Connect to client - OK");

while (1) {

    my $tasks = eval { $storage->get_ready_tasks };
    if ( my $error = $@ ) {
        $logger->error("Get ready tasks - Error: <$error>");
    }
    else {
        $logger->info("Get ready tasks - OK");
    }

    if ( scalar $tasks ) {

        foreach my $task (@{$tasks}){

            my $message = eval { decode_json $task->{command} };
            if ( my $error = $@ ) {
                $logger->error("Decode from json - Error: <$error>");
                next;
            }
            else {
                $logger->info("Decode from json - OK, Body: $task->{command}");
            }

            $message->{id} = $task->{transaction_id};
            $message->{task_id} = $task->{id};

            if ( ! $message->{address} ) {
                $logger->error("Address empty, Body: $task->{command} ",
                    "id = $task->{transaction_id}, task_id = $task->{id}");
                next;
            }

            eval { $client->set_queue( $message->{address} ) };
            if ( my $error = $@ ) {
                $logger->error("Set queue - Error: <$error> ",
                    "Queue: $message->{address}, id = $task->{transaction_id} ",
                        "task_id = $task->{id}");
                next;
            }
            else {
                $logger->info("Set queue - OK, Queue: $message->{address} ",
                    "id = $task->{transaction_id}, task_id = $task->{id}");
            }

            eval { $storage->update_task( $task->{id}, 'running' ) };
            if ( my $error = $@ ) {
                $logger->error("Update task - Error: <$error>, ",
                    "id = $task->{transaction_id}, task_id = $task->{id}");
                next;
            }
            else {
                $logger->info("Update task - OK, ",
                    "id = $task->{transaction_id}, task_id = $task->{id}");
            }

            eval { $client->send( encode_json $message ) };
            if ( my $error = $@ ) {
                $logger->error("Send message - Error: <$error>, ",
                    "id = $task->{transaction_id}, task_id = $task->{id}");
                next;
            }
            else {
                $logger->info("Send message - OK, ",
                    "id = $task->{transaction_id}, task_id = $task->{id}");
            }
        }
    }

    $logger->info("Waiting for the signal");
    $signal->wait;
}
