package FMQueue::Storage::PG;

use strict;
use warnings;

use DBI;

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub init {
    my ( $self, $dsn, $user, $pass ) = @_;

    $self->{dsn}  = $dsn;
    $self->{user} = $user;
    $self->{pass} = $pass;
    $self->{dbh}  = '';

    $self->{task_factory} = '';

    return $self;
}

sub task_factory {
    my ( $self, $task_factory ) = @_;

    $self->{task_factory} = $task_factory if defined $task_factory;

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

sub submit_job {
    my ( $self, $job ) = @_;

    $self->{dbh}->begin_work;

    $self->_insert_job($job);

    $self->{dbh}->commit;
}

sub _insert_job {
    my ( $self, $job ) = @_;

    my $insert_gob_sql =
        q{INSERT INTO transactions (id,status,account,start_timestamp,
            status_timestamp) VALUES (?,?,?,current_timestamp,current_timestamp)};

    $self->{dbh}->do(
        $insert_gob_sql,
        undef,
        ( $job->id, 'ready', $job->user_id )
    );

    foreach my $task (@{$job->tasks}) {
        $self->_insert_task($task);
    }
}

sub _insert_task {
    my ( $self, $task ) = @_;

    my $insert_task_sql =
        q{INSERT INTO tasks (id,transaction_id,status,command,step,
            start_timestamp,status_timestamp) VALUES(?,?,?,?,?,
                current_timestamp,current_timestamp)};

    my $status = ($task->step == 1) ? 'ready' : 'wait';

    $self->{dbh}->do(
        $insert_task_sql,
        undef,
        ( $task->id, $task->job_id, $status, $task->to_string, $task->step )
    );
}

sub set_task_result {
    my ( $self, $task ) = @_;

    $self->{dbh}->begin_work;

    $self->_update_task($task);

    $self->{dbh}->commit;
}

sub _update_task {
    my ( $self, $task ) = @_;

    my $update_task_sql =
        q{UPDATE tasks SET status = ?, status_text = ?,
            status_timestamp = current_timestamp WHERE id = ?};

    my $status = $task->is_status_error ? 'error' : 'complete';

    $self->{dbh}->do(
        $update_task_sql,
        undef,
        ( $status, $task->result->{text}, $task->id )
    );

    if ( $task->is_last_task or $task->is_status_error) {
        $self->_update_job($task);
    }
    else {
        $self->_set_next_step($task);
    }
}

sub _update_job {
    my ( $self, $task ) = @_;

    my $update_job_sql =
        q{UPDATE transactions SET status = ?,
            status_timestamp = current_timestamp WHERE id = ?};

    my $status = $task->is_status_error ? 'error' : 'complete';

    $self->{dbh}->do(
        $update_job_sql,
        undef,
        ( $status, $task->job_id )
    );
}

sub _set_next_step {
    my ( $self, $task ) = @_;

    my $set_next_step_sql =
        q{UPDATE tasks SET status = ?,
            status_timestamp = current_timestamp WHERE transaction_id = ?
                AND step = ?};

    $self->{dbh}->do(
        $set_next_step_sql,
        undef,
        ( 'ready', $task->job_id, $task->step + 1 )
    );
}

sub get_ready_tasks {
    my ($self) = @_;

    my $result_set = [];
    my $get_ready_tasks_sql = q{SELECT * FROM tasks WHERE status = ?};

    my $sth = $self->{dbh}->prepare($get_ready_tasks_sql);
    $sth->execute('ready');

    while(my $ref = $sth->fetchrow_hashref) {
        my $task = $self->{task_factory}->task;

        $task->from_string($ref->{command});

        push @{$result_set}, $task;
    }

    return $result_set;
}

sub processing_task {
    my ( $self, $task ) = @_;

    my $processing_task_sql =
        q{UPDATE tasks SET status = ?, status_timestamp = current_timestamp
            WHERE id = ?};

    $self->{dbh}->begin_work;

    $self->{dbh}->do(
        $processing_task_sql,
        undef,
        ( 'running', $task->id )
    );

    $self->_set_job_running($task) if $task->step == 1;

    $self->{dbh}->commit;
}

sub _set_job_running {
    my ( $self, $task ) = @_;

    my $set_job_running_sql =
        q{UPDATE transactions SET status = ?,
            status_timestamp = current_timestamp WHERE id = ?};

    $self->{dbh}->do(
        $set_job_running_sql,
        undef,
        ( 'running', $task->job_id )
    );
}

1;
