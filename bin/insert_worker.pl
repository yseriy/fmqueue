use strict;
use warnings;

use JSON;
use FMQueue::Factory::RabbitPG;

my $config_path = '/usr/local/fmqueue/etc/insert_worker.conf';
my $factory = FMQueue::Factory::RabbitPG->new($config_path);

my $log = $factory->log;
my $storage = $factory->storage;
my $worker  = $factory->worker;
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

eval{ $worker->connect };
if ( my $error = $@ ) {
    $logger->logdie("Connect to worker - Error: <$error>");
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

    if ( ! $message->{account} ) {
        $logger->error("Empty account, Body: $body");
        next;
    }

    my $id = eval { $storage->start_transaction( $body, $message->{account} ) };
    if ( my $error = $@ ) {
        $logger->error("Start transaction - Error: <$error>, Body: $body");
        next;
    }
    else {
        $logger->info("Start transaction - OK, id = $id");
    }

    eval { $worker->send_ack($id) };
    if ( my $error = $@ ) {
        $logger->error("Send ACK - Error: <$error>, id = $id");
        next;
    }
    else {
        $logger->info("Send ACK - OK, id = $id");
    }

    $logger->info("Send signal");
    $signal->send;
};
