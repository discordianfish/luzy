package Mojolicious::Plugin::Cms::Store::Cache;
use base 'Mojolicious::Plugin::Cms::Store';

use strict;
use warnings;

__PACKAGE__->attr(cache => sub { $_[0]->cms->cache });
__PACKAGE__->attr(store => sub { $_[0]->cms->store });

sub _retrieve {
    my $self   = shift;
    my $method = shift;
    my $set_it = shift;

    my $id = join '.', grep {$_} @_;
    my $rc = $self->cache->get($id);
    unless (defined $rc) {
        $rc = $self->store->$method(@_);
        $self->cache->set($id, $rc) if $set_it && defined $rc;
    }
    return $rc;
}

sub _get {
    my $self   = shift;
    my $method = shift;

    return $self->_retrieve($method, 1, @_);
}

sub _get_only {
    my $self   = shift;
    my $method = shift;

    return $self->_retrieve($method, 0, @_);
}

# backup to the store only, don't cache it
sub backup { shift->store->backup(@_) }

sub exists {
    my $self = shift;
    return $self->_get_only(exists => @_);
}

sub list {
    my $self = shift;
    return $self->store->list(@_);
}

sub list_by_category {
    my $self = shift;
    return $self->_get(list_by_category => @_);
}

sub list_by_tag {
    my $self = shift;
    return $self->_get(list_by_tag => @_);
}

sub load {
    my $self = shift;
    return $self->_get(load => @_);
}

# restore from the store only, not from the cache
sub restore { shift->store->restore(@_) }

sub save {
    my $self    = shift;
    my $content = pop;

    my $id = join '.', grep {$_} @_;
    my $rc = $self->store->save(@_, $content);
    $self->cache->set($id, $content) if $rc;
    return $rc;
}

1;
