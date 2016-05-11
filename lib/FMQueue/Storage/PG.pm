package FMQueue::Storage::PG;

use strict;
use warnings;

use DBI;

sub new {
    my ($class) = @_;

    my $self = {};

    $self->{dsn}  = '';
    $self->{user} = '';
    $self->{pass} = '';
    $self->{dbh}  = '';

    return bless $self, $class;
}

sub dsn {
    my ( $self, $dsn ) = @_;

    $self->{dsn} = $dsn if $dsn;

    return $self;
}

sub user {
    my ( $self, $user ) = @_;

    $self->{user} = $user if $user;

    return $self;
}

sub pass {
    my ( $self, $pass ) = @_;

    $self->{pass} = $pass if $pass;

    return $self;
}

sub connect {
    my ($self) = @_;

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

sub insert_sequence {
    my ( $self, $sequence ) = @_;

    my $table1 = q{INSERT INTO transactions
                    (id,status,start_timestamp,status_timestamp,account)
                        VALUES (?,?,current_timestamp,current_timestamp,?)};
    my $table2 = q{INSERT INTO tasks
                    (id,transaction_id,status,command,step,start_timestamp,
                        status_timestamp)
                            VALUES(?,?,?,?,?,current_timestamp,
                                current_timestamp)};

    my $sequence_id = $sequence->id;
    my $user_id     = $sequence->user_id;
    my $tasks       = $sequence->tasks;

    $self->{dbh}->begin_work;

    $self->{dbh}->do( $table1, undef, ( $sequence_id, 'runnig', $user_id ) );

    my $step = 0;
    foreach my $task (@{$tasks}){
        $step += 1;

        my $status = ($step == 1) ? 'ready' : 'new';

        $self->{dbh}->do(
            $table2,
            undef,
            ( $task->task_id, $task->seq_id, $status, $task->to_string, $step )
        );
    }

    $self->{dbh}->commit;
}

sub update_sequence {
    my ( $self, $task ) = @_;

    $self->{dbh}->begin_work;

    if ( ! $task->result->{rc} ) {
        $self->set_sequence_status( $task->seq_id, 'running');
        $self->set_task_status( $task->task_id, 'complete', $task->result->{text} );
        $self->get_next_step($task->seq_id);
    }
    else {

    }

    $self->{dbh}->commit;
}

sub set_sequence_status {
    my ( $self, $seq_id, $status ) = @_;

    my $table = q{UPDATE transactions SET status = ?,
                    status_timestamp = current_timestamp WHERE id = ?};

    $self->{dbh}->do( $table, undef, ( $status, $seq_id ) );
}

sub set_task_status {
    my ( $self, $task_id, $status, $status_text ) = @_;

    my $tasks_table = q{UPDATE tasks SET status = ?, status_text = ?,
                    status_timestamp = current_timestamp WHERE id = ?};

    $self->{dbh}->do( $tasks_table, undef, ( $status, $task_id, $status_text ) );
}

sub get_next_step {
    my ( $self, $seq_id ) = @_;

    my $select = q{SELECT id FROM tasks WHERE transaction_id = ? AND step IN
                    (SELECT MIN(step) FROM tasks
                        WHERE transaction_id = ? AND status = 'new')};

    my $task = $self->{dbh}->selectrow_hashref( $select, undef, ($seq_id) );

    return $task->{id} ? $self->set_next_step($task->{id}) : 0;
}

sub set_next_step {
    my ( $self, $task_id ) = @_;

    my $tasks_table = q{UPDATE tasks SET status = ?,
                    status_timestamp = current_timestamp WHERE id = ?};

    return $self->{dbh}->do( $tasks_table, undef, ( 'ready', $task_id ) );
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
