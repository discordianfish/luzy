package Mojolicious::Plugin::Cms::Converter;
use base 'Mojo::Base';

use warnings;
use strict;
use Carp ();

sub to_html { Carp::croak 'Method unimplemented by subclass!' }

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Converter - just a converter

=head1 DESCRIPTION

A Mojolicious::Plugin::Cms::Converter is a thing that can convert
data. This is an abstract base class.

=head1 IMPLEMENTATIONS SHIPPED WITH THIS DISTRIBUTION

=over 4

=item L<Mojolicious::Plugin::Cms::Converter::None>

This converter actually does nothing.

=back

=head1 METHODS

If you want to be a thing that can convert data, you need to
implement the following methods:

=head2 to_html

    my $html = $type->to_html($input);

Output needs to be html.

=head1 SEE ALSO

L<Mojolicious::Plugin::Cms>
