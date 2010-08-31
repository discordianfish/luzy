package Mojolicious::Plugin::Cms::Store::Cache;
use base 'Mojolicious::Plugin::Cms::Store';

use strict;
use warnings;

__PACKAGE__->attr([qw/cms/]);
__PACKAGE__->attr(store => sub { $_[0]->cms->store });
__PACKAGE__->attr(cache => sub { $_[0]->cms->cache });

sub exists {
    my $self = shift;

    my $id = join '.', grep {$_} @_;
    my $rc =
        $self->cache->can('exists')
      ? $self->cache->exists($id)
      : defined $self->cache->get($id);
    $rc = $self->store->exists(@_) unless $rc;
    return $rc;
}

sub list {
    my $self = shift;

    return $self->store->list(@_);
}

sub load {
    my $self = shift;

    my $id = join '.', grep {$_} @_;
    my $rc = $self->cache->get($id);
    unless (defined $rc) {
        $rc = $self->store->load(@_);
        $self->cache->set($id, $rc) if defined $rc;
    }
    return $rc;
}

sub save {
    my $self    = shift;
    my $content = pop;

    my $id = join '.', grep {$_} @_;
    my $rc = $self->store->save(@_, $content);
    $self->cache->set($id, $content) if $rc;
    return $rc;
}

1;
