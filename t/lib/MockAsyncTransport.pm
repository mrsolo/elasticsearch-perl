package MockAsyncTransport;

use strict;
use warnings;

our $VERSION = $Elasticsearch::VERSION;

use AE;
use Moo;
extends 'Elasticsearch::Transport::Async';

our $w;
#===================================
sub perform_sync_request {
#===================================
    my $self = shift;
    my $cv   = AE::cv;
    $w = AE::timer( 1, 0,
        sub { $cv->croak('Response timed out'); undef $w } );
    my $promise = $self->perform_request(@_);
    $promise->then( sub {  $cv->send(@_) }, sub { $cv->croak(@_) } );
    $cv->recv;
}

1
