package Mojolicious::Plugin::Cms::Content;
use base 'Mojo::Base';

use strict;
use warnings;

use overload '""' => sub { shift->raw };

use Scalar::Util qw/blessed/;
use List::Util qw/first/;

my %META_ATTRS = (
    categories => [],
    tags       => [],
    title      => undef,
);
my %DATA_ATTRS = (
    language => undef,
    path     => undef,
    raw      => undef,
);

foreach my $hash (\%META_ATTRS, \%DATA_ATTRS) {
    while (my ($k, $v) = each %$hash) {
        __PACKAGE__->attr($k => sub {$v});
    }
}
__PACKAGE__->attr(id => undef);
__PACKAGE__->attr(modified => sub {time});

sub _array_to_string {
    my ($self, $array) = @_;
    return join ', ', sort @$array;
}

sub categories_to_string {
    my $self = shift;
    return $self->_array_to_string($self->categories);
}

sub has_category {
    my ($self, $category) = @_;
    return first { lc($_) eq lc($category) } @{$self->categories};
}

sub has_tag {
    my ($self, $tag) = @_;
    return first { lc($_) eq lc($tag) } @{$self->tags};
}

sub meta_data {
    my $self = shift;

    return {map { $_ => $self->$_ } grep { $self->$_ } keys %META_ATTRS};
}

sub save_to {
    my ($self, $store) = @_;
    return $store->save($self->path, $self->language, $self);
}

sub tags_to_string {
    my $self = shift;
    return $self->_array_to_string($self->tags);
}

sub _update_from_group {
    my ($self, $getter, $group) = @_;

    while (my ($gkey, $gval) = each %$group) {
        my $value = $getter->($gkey);
        $self->$gkey($value) if defined $value;
    }
}

sub update_from {
    my ($self, $req) = @_;

    my $getter =
      blessed($req)
      ? sub { $req->param($_[0]) }
      : sub { exists $req->{$_[0]} ? $req->{$_[0]} : undef };

    foreach my $group (\%DATA_ATTRS, \%META_ATTRS) {
        $self->_update_from_group($getter, $group);
    }

    return $self;
}

1;
