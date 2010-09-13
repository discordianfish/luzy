package Mojolicious::Plugin::Cms::Converter::Markdown;
use base 'Mojolicious::Plugin::Cms::Converter';

use strict;
use warnings;

use Text::Markdown ();

__PACKAGE__->attr(empty_element_suffix    => ' />');
__PACKAGE__->attr(tab_width               => 4);
__PACKAGE__->attr(markdown_in_html_blocks => 0);
__PACKAGE__->attr(trust_list_start_value  => 0);

__PACKAGE__->attr(
    _converter => sub {
        my $self = shift;
        return Text::Markdown->new(
            empty_element_suffix    => $self->empty_element_suffix,
            tab_width               => $self->tab_width,
            markdown_in_html_blocks => $self->markdown_in_html_blocks,
            trust_list_start_value  => $self->trust_list_start_value,
        );
    }
);

sub name {'markdown'}

sub to_html {
    my ($self, $input) = @_;
    return $self->_converter->markdown($input || '');
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Converter::Markdown - markdown managed format

=head1 SYNOPSIS

    my $html = $none->to_html($input);

=head1 DESCRIPTION

Mojolicious::Plugin::Cms::Converter::Markdown converts input in markdown to html

=head1 METHODS

=head2 name

	my $name = $none->name;

Returns the name of the converter: 'markdown'

=head2 to_html

    my $html = $markdown->to_html($input);

The to_html function.

=head1 SEE ALSO

L<Mojolicious::Plugin::Cms>,
L<Mojolicious::Plugin::Cms::Converter>

