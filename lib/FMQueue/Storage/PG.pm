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

    my $status = ($task->step == 1) ? 'ready' : 'wait';

    $self->{dbh}->do(
        $task_insert_sql,
        undef,
        ( $task->id, $task->seq_id, $status, $task->to_string, $task->step )
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
    else {
        $self->_setup_next_step($task);
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

sub _setup_next_step {
    my ( $self, $task ) = @_;

    my $setup_next_step_sql =
        q{UPDATE tasks SET status = ?,
            status_timestamp = current_timestamp WHERE transaction_id = ?
                AND step = ?};

    $self->{dbh}->do(
        $setup_next_step_sql,
        undef,
        ( 'ready', $task->seq_id, $task->step + 1 )
    );
}

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
