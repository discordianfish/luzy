package Mojolicious::Plugin::Cms::Format;
use base 'Mojo::Base';

use warnings;
use strict;
use Carp ();

sub translate { Carp::croak 'Method unimplemented by subclass!' }

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Format - abstract managed format

=head1 DESCRIPTION

A Mojolicious::Plugin::Cms::Format is a thing that can translate
pages to html. This is an abstract base class.

=head1 IMPLEMENTATIONS SHIPPED WITH THIS DISTRIBUTION

=over 4

=item L<Mojolicious::Plugin::Cms::Format::None>

This translator actually does nothing. Perfect if you want to store plain
html content pages

=back

=head1 METHODS

If you want to be a thing that can translate pages to html, you need to
implement the following methods:

=head2 translate

    my $html = $type->translate($input);

Output needs to be html.

=head1 SEE ALSO

L<Mojolicious::Plugin::Cms>
