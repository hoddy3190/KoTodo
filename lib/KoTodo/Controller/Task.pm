package KoTodo::Controller::Task;

use strict;
use warnings;
use utf8;

use KoTodo::Model::Task;

my $STATUS_SUCCESS = 1;
my $STATUS_ERROR   = 0;

my $ERR_MSG = 'Internal Server Error';

sub new {
    my ($class, $dbh) = @_;
    bless +{
        _model => KoTodo::Model::Task->new($dbh),
    }, $class;
}

sub index {
    my $self = shift;
    $self->{_model}->select_all;
}

sub create {
    my ($self, $params) = @_;
    my $res;
    eval {
        $self->{_model}->create($params);
        $res = $self->_make_status_jsodn_res($STATUS_SUCCESS);
    };
    if ($@) {
        # TODO: $@ will be sent to log files
        $res = $self->_make_status_json_res($STATUS_ERROR);
    }
    $res;
}

sub _make_status_json_res {
    my ($self, $status, $options) = @_;
    if ($status == $STATUS_SUCCESS) {
        +{status => $status};
    } else {
        $status = $STATUS_ERROR;
        my $err_msg = $options->{err_msg} || $ERR_MSG;
        +{status => $status, error => +{messages => $err_msg}};
    }
}

1;
