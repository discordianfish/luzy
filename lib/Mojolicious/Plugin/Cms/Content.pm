package Mojolicious::Plugin::Cms::Content;
use base 'Mojo::Base';

use overload '""' => sub { shift->data };

use warnings;
use strict;

__PACKAGE__->attr([qw/data modified language/]);

1;