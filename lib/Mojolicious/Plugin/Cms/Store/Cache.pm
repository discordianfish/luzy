package Mojolicious::Plugin::Cms::Store::Cache;
use base 'Mojolicious::Plugin::Cms::Store';

use strict;
use warnings;

use Carp ();

__PACKAGE__->attr(cache => sub { $_[0]->cms->cache });
__PACKAGE__->attr(store => sub { $_[0]->cms->store });

sub _retrieve {
    my $self             = shift;
    my $method           = shift;
    my $set_it           = shift;
    my $add_method_to_id = shift;

    my $id = join '.', grep {$_} $add_method_to_id ? ($method, @_) : @_;
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

    return $self->_retrieve($method, 1, 0, @_);
}

sub _get_only {
    my $self   = shift;
    my $method = shift;

    return $self->_retrieve($method, 0, 0, @_);
}

sub all_categories {
    my $self = shift;
    return $self->_retrieve(all_categories => 1, 1, @_);
}

sub all_tags {
    my $self = shift;
    return $self->_retrieve(all_tags => 1, 1, @_);
}

# backup to the store only, don't cache it
sub backup { shift->store->backup(@_) }

sub delete {
    my $self  = shift;
    my $thing = $_[0];

    my $id;
    if (ref $thing && $thing->isa('Mojolicious::Plugin::Cms::Content')) {
        $id = join '.', grep {$_} $thing->path, $thing->language;
    }
    else {
        $id = join '.', grep {$_} @_;
    }

    $self->cache->set($id, undef);
    return $self->store->delete(@_);
}

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
    my $content = shift;

    Carp::croak "Path not set."     unless $content->path;
    Carp::croak "Language not set." unless $content->language;

    my $id = join '.', grep {$_} $content->path, $content->language;
    my $rc = $self->store->save($content);
    $self->cache->set($id, $content) if $rc;
    return $rc;
}

1;
