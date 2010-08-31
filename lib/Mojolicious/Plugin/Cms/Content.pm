package Mojolicious::Plugin::Cms::Content;
use base 'Mojo::Base';

use overload '""' => sub { shift->raw };

use warnings;
use strict;

__PACKAGE__->attr([qw/language path raw/]);
__PACKAGE__->attr(modified => sub {time});

sub set_from {
    my ($self, $req) = @_;

    foreach my $p (qw/language path raw/) {
        $self->$p($req->param($p) || '');
    }

    return $self;
}

sub save_to {
    my ($self, $store) = @_;

    return $store->save($self->path, $self->language, $self);
}

1;
