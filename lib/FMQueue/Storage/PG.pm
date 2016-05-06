package FMQueue::Storage::PG;

use strict;
use warnings;

use DBI;
use Data::UUID;

sub new {
    my ( $class, $config ) = @_;

    my $self = {};

    $self->{dsn}  = '';
    $self->{user} = '';
    $self->{pass} = '';
    $self->{dbh}  = '';
    $self->{config} = $config;
    $self->{uuid}   = Data::UUID->new;

    return bless $self, $class;
}

sub read_config {
    my ($self) = @_;

    my $parameters = $self->{config}->parameters;

    $self->{dsn} = "dbi:Pg:dbname=$parameters->{dbname};"
                 . "host=$parameters->{host};"
                 . "port=$parameters->{port};";

    $self->{user} = $parameters->{user} || '';
    $self->{pass} = $parameters->{pass} || '';    
}

sub connect {
    my ($self) = @_;

    $self->read_config;

    $self->{dbh} = DBI->connect(
        $self->{dsn},
        $self->{user},
        $self->{pass},
        { AutoCommit => 1, RaiseError => 1 }
    );

    return 1;
}

sub disconnect {
    my ($self) = @_;

    $self->{dbh}->disconnect;

    return 1;
}

sub reconnect {
    my ($self) = @_;

    $self->connect if ! $self->{dbh}->ping;
}

sub start_transaction {
    my ( $self, $body, $account ) = @_;

    my $table1 = q{INSERT INTO transactions
                    (id,status,start_timestamp,status_timestamp,account)
                        VALUES (?,?,current_timestamp,current_timestamp,?)};
    my $table2 = q{INSERT INTO tasks
                    (id,transaction_id,status, 
                        command,start_timestamp,status_timestamp)
                            VALUES (?,?,?,?,current_timestamp,current_timestamp)};

    my $uuid1 = $self->{uuid}->create_str;
    my $uuid2 = $self->{uuid}->create_str;

    $self->{dbh}->begin_work;

    $self->{dbh}->do( $table1, undef, ( $uuid1, 'runnig', $account ) );
    $self->{dbh}->do( $table2, undef, ( $uuid2, $uuid1, 'ready', $body ) );
    
    $self->{dbh}->commit;

    return $uuid1;
}

sub update_transaction {
    my ( $self, $id, $task_id, $result ) = @_;

    my $table1 = q{UPDATE transactions SET status = ?,
                    status_timestamp = current_timestamp WHERE id = ?};
    my $table2 = q{UPDATE tasks SET status = ?, status_text = ?,
                    status_timestamp = current_timestamp WHERE id = ?};

    my $task_status = $result->{rc} ? 'error' : 'comlete';
    my $transaction_status = $task_status;

    $self->{dbh}->begin_work;

    $self->{dbh}->do( $table1, undef, ( $transaction_status, $id ) );
    $self->{dbh}->do( $table2, undef, ( $task_status, $result->{text}, $task_id ) );
    
    $self->{dbh}->commit;
}

sub update_task {
    my ( $self, $task_id, $status ) = @_;

    my $tasks_table = q{UPDATE tasks SET status = ?,
                    status_timestamp = current_timestamp WHERE id = ?};

    $self->{dbh}->do( $tasks_table, undef, ( $status, $task_id ) );    
}

sub get_ready_tasks {
    my ($self) = @_;

    my $result_set   = [];
    my $ready_status = 'ready';
    my $sql = q{SELECT * FROM tasks WHERE status = ?};

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($ready_status);

    while(my $ref = $sth->fetchrow_hashref) {
        push @{$result_set}, $ref;
    }

    return $result_set;
}

1;
