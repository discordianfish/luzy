package Mojolicious::Plugin::Cms::Resolver::DOM;
use base 'Mojolicious::Plugin::Cms::Resolver';

use Mojo::DOM;

__PACKAGE__->attr(parser => sub { Mojo::DOM->new->charset(undef) });

1;
