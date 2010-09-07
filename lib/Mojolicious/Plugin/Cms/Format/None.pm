package Mojolicious::Plugin::Cms::Format::None;
use base 'Mojolicious::Plugin::Cms::Format';

use warnings;
use strict;

sub translate {
    my ($self, $input) = @_;
    $input = $input->raw if ref($input) && $input->isa('Mojolicious::Plugin::Cms::Content');
    return $input;
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Format::None - none managed format

=head1 SYNOPSIS

    my $html = $none->translate($input);

=head1 DESCRIPTION

Mojolicious::Plugin::Cms::Format::None does not very much. It translates something to html if it is html.

=head1 METHODS

=head2 translate

    my $html = $none->translate($input);

The translate function.

=head1 SEE ALSO

L<Mojolicious::Plugin::Cms>,
L<Mojolicious::Plugin::Cms::Format>

