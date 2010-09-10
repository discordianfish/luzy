package Mojolicious::Plugin::Cms::Converter::None;
use base 'Mojolicious::Plugin::Cms::Converter';

use warnings;
use strict;

sub to_html {
    my ($self, $input) = @_;   
    return $input;
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Converter::None - none managed format

=head1 SYNOPSIS

    my $html = $none->to_html($input);

=head1 DESCRIPTION

Mojolicious::Plugin::Cms::Converter::None does not very much. It converts something to html if it is html.

=head1 METHODS

=head2 to_html

    my $html = $none->to_html($input);

The to_html function.

=head1 SEE ALSO

L<Mojolicious::Plugin::Cms>,
L<Mojolicious::Plugin::Cms::Converter>

