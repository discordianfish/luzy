package Mojolicious::Plugin::Cms::Store;
use base 'Mojo::Base';

use warnings;
use strict;

use Carp ();

__PACKAGE__->attr([qw/cms/]);
__PACKAGE__->attr(app => sub { $_[0]->cms->app });

sub all_categories { Carp::croak 'Method \'all_categories\' unimplemented by subclass!' }

sub all_tags { Carp::croak 'Method \'all_tags\' unimplemented by subclass!' }

sub backup { Carp::croak 'Method \'backup\' unimplemented by subclass!' }

sub delete { Carp::croak 'Method \'delete\' unimplemented by subclass!' }

sub exists { Carp::croak 'Method \'exists\' unimplemented by subclass!' }

sub list { Carp::croak 'Method \'list\' unimplemented by subclass!' }

sub list_by_category { Carp::croak 'Method \'list_by_category\' unimplemented by subclass!' }

sub list_by_tag { Carp::croak 'Method \'list_by_tag\' unimplemented by subclass!' }

sub load { Carp::croak 'Method \'load\' unimplemented by subclass!' }

sub restore { Carp::croak 'Method \'restore\' unimplemented by subclass!' }

sub revisions { Carp::croak 'Method \'revisions\' unimplemented by subclass!' }

sub save { Carp::croak 'Method \'save\' unimplemented by subclass!' }

1;
