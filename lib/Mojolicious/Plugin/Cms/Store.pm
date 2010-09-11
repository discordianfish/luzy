package Mojolicious::Plugin::Cms::Store;
use base 'Mojo::Base';

use warnings;
use strict;

use Carp ();

__PACKAGE__->attr([qw/cms/]);
__PACKAGE__->attr(app => sub { $_[0]->cms->app });

sub all_categories { Carp::croak 'Method unimplemented by subclass!' }

sub all_tags { Carp::croak 'Method unimplemented by subclass!' }

sub backup { Carp::croak 'Method unimplemented by subclass!' }

sub delete { Carp::croak 'Method unimplemented by subclass!' }

sub exists { Carp::croak 'Method unimplemented by subclass!' }

sub list { Carp::croak 'Method unimplemented by subclass!' }

sub list_by_category { Carp::croak 'Method unimplemented by subclass!' }

sub list_by_tag { Carp::croak 'Method unimplemented by subclass!' }

sub load { Carp::croak 'Method unimplemented by subclass!' }

sub restore { Carp::croak 'Method unimplemented by subclass!' }

sub save { Carp::croak 'Method unimplemented by subclass!' }

1;
