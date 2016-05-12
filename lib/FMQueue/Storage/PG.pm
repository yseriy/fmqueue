package FMQueue::Storage::PG;

use strict;
use warnings;

use DBI;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ( $self, $dns, $user, $pass ) = @_;

    $self->{dsn}  = $dns;
    $self->{user} = $user;
    $self->{pass} = $pass;
    $self->{dbh}  = '';

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
}

sub disconnect {
    my ($self) = @_;

    $self->{dbh}->disconnect;
}

sub reconnect {
    my ($self) = @_;

    $self->connect if ! $self->{dbh}->ping;
}

sub insert_sequence {
    my ( $self, $sequence ) = @_;

    $self->{dbh}->begin_work;

    $self->_insert_sequence($sequence);

    $self->{dbh}->commit;
}

sub _insert_sequence {
    my ( $self, $sequence ) = @_;

    my $sequence_insert_sql =
        q{INSERT INTO transactions (id,status,account,start_timestamp,
            status_timestamp) VALUES (?,?,?,current_timestamp,current_timestamp)};

    $self->{dbh}->do(
        $sequence_insert_sql,
        undef,
        ( $sequence->id, 'ready', $sequence->user_id )
    );

    foreach my $task (@{$sequence->tasks}) {
        $self->_insert_task($task);
    }
}

sub _insert_task {
    my ( $self, $task ) = @_;

    my $task_insert_sql =
        q{INSERT INTO tasks (id,transaction_id,status,command,step,
            start_timestamp,status_timestamp) VALUES(?,?,?,?,?,
                current_timestamp,current_timestamp)};

    $self->{dbh}->do(
        $task_insert_sql,
        undef,
        ( $task->id, $task->seq_id, 'ready', $task->to_string, $task->step )
    );
}

sub update_task {
    my ( $self, $task ) = @_;

    $self->{dbh}->begin_work;

    $self->_update_task($task);

    $self->{dbh}->commit;
}

sub _update_task {
    my ( $self, $task ) = @_;

    my $task_update_sql =
        q{UPDATE tasks SET status = ?, status_text = ?,
            status_timestamp = current_timestamp WHERE id = ?};

    my $status = $task->is_status_error ? 'error' : 'complete';

    $self->{dbh}->do(
        $task_update_sql,
        undef,
        ( $status, $task->result->{text}, $task->id )
    );

    if ( $task->is_last_task or $task->is_status_error) {
        $self->_update_sequence($task);
    }
}

sub _update_sequence {
    my ( $self, $task ) = @_;

    my $sequence_update_sql =
        q{UPDATE transactions SET status = ?,
            status_timestamp = current_timestamp WHERE id = ?};

    my $status = $task->is_status_error ? 'error' : 'complete';

    $self->{dbh}->do(
        $sequence_update_sql,
        undef,
        ( $status, $task->seq_id )
    );
}

# sub update_sequence {
#     my ( $self, $task ) = @_;
#
#     $self->{dbh}->begin_work;
#
#     if ( ! $task->result->{rc} ) {
#         $self->set_sequence_status( $task->seq_id, 'running');
#         $self->set_task_status( $task->task_id, 'complete', $task->result->{text} );
#         $self->get_next_step($task->seq_id);
#     }
#     else {
#
#     }
#
#     $self->{dbh}->commit;
# }
#
# sub set_sequence_status {
#     my ( $self, $seq_id, $status ) = @_;
#
#     my $table = q{UPDATE transactions SET status = ?,
#                     status_timestamp = current_timestamp WHERE id = ?};
#
#     $self->{dbh}->do( $table, undef, ( $status, $seq_id ) );
# }
#
# sub set_task_status {
#     my ( $self, $task_id, $status, $status_text ) = @_;
#
#     my $tasks_table = q{UPDATE tasks SET status = ?, status_text = ?,
#                     status_timestamp = current_timestamp WHERE id = ?};
#
#     $self->{dbh}->do( $tasks_table, undef, ( $status, $task_id, $status_text ) );
# }
#
# sub get_next_step {
#     my ( $self, $seq_id ) = @_;
#
#     my $select = q{SELECT id FROM tasks WHERE transaction_id = ? AND step IN
#                     (SELECT MIN(step) FROM tasks
#                         WHERE transaction_id = ? AND status = 'new')};
#
#     my $task = $self->{dbh}->selectrow_hashref( $select, undef, ($seq_id) );
#
#     return $task->{id} ? $self->set_next_step($task->{id}) : 0;
# }
#
# sub set_next_step {
#     my ( $self, $task_id ) = @_;
#
#     my $tasks_table = q{UPDATE tasks SET status = ?,
#                     status_timestamp = current_timestamp WHERE id = ?};
#
#     return $self->{dbh}->do( $tasks_table, undef, ( 'ready', $task_id ) );
# }
#
# sub get_ready_tasks {
#     my ($self) = @_;
#
#     my $result_set   = [];
#     my $ready_status = 'ready';
#     my $sql = q{SELECT * FROM tasks WHERE status = ?};
#
#     my $sth = $self->{dbh}->prepare($sql);
#
#     $sth->execute($ready_status);
#
#     while(my $ref = $sth->fetchrow_hashref) {
#         push @{$result_set}, $ref;
#     }
#
#     return $result_set;
# }

1;
