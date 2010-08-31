package Mojolicious::Plugin::Cms::Controller::Admin;
use base 'Mojolicious::Plugin::Cms::Controller';

use strict;
use warnings;

use Mojo::Path;
use Mojolicious::Plugin::Cms::Content;

sub save {
    my $self = shift;

    # check required parameters
    foreach my $p (qw/language path raw/) {
        unless (defined $self->param($p)) {
            $self->app->static->serve_404;
            return;
        }
    }

    my $c = Mojolicious::Plugin::Cms::Content->new;
    $c->set_from($self);

    # do some path fixing
    my $p = Mojo::Path->new($c->path || '/');
    $p = $p->append($self->cms->default)
      if $p->trailing_slash;
    $c->path($p);
    $c->save_to($self->_store);
}

1;
