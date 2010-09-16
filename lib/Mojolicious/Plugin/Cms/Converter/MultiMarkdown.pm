package Mojolicious::Plugin::Cms::Converter::MultiMarkdown;
use base 'Mojolicious::Plugin::Cms::Converter';

use strict;
use warnings;

use Text::MultiMarkdown ();

__PACKAGE__->attr( [qw/base_url document_format use_wikilinks/] );
__PACKAGE__->attr( bibliography_title      => '' );
__PACKAGE__->attr( disable_bibliography    => 0 );
__PACKAGE__->attr( disable_footnotes       => 0 );
__PACKAGE__->attr( disable_tables          => 0 );
__PACKAGE__->attr( empty_element_suffix    => ' />' );
__PACKAGE__->attr( heading_ids             => 1 );
__PACKAGE__->attr( img_ids                 => 1 );
__PACKAGE__->attr( tab_width               => 4 );
__PACKAGE__->attr( markdown_in_html_blocks => 0 );
__PACKAGE__->attr( strip_metadata          => 0 );
__PACKAGE__->attr( trust_list_start_value  => 0 );
__PACKAGE__->attr( use_metadata            => 1 );

__PACKAGE__->attr(
    _converter => sub {
        my $self = shift;
        return Text::MultiMarkdown->new(
            base_url                => $self->base_url,
            bibliography_title      => $self->bibliography_title,
            disable_bibliography    => $self->disable_bibliography,
            disable_footnotes       => $self->disable_footnotes,
            disable_tables          => $self->disable_tables,
            document_format         => $self->document_format,
            empty_element_suffix    => $self->empty_element_suffix,
            heading_ids             => $self->heading_ids,
            img_ids                 => $self->img_ids,
            tab_width               => $self->tab_width,
            markdown_in_html_blocks => $self->markdown_in_html_blocks,
            strip_metadata          => $self->strip_metadata,
            trust_list_start_value  => $self->trust_list_start_value,
            use_metadata            => $self->use_metadata,
            use_wikilinks           => $self->use_wikilinks,
        );
    }
);

sub name { 'multi_markdown' }

sub to_html {
    my ( $self, $input ) = @_;
    return $self->_converter->markdown( $input || '' );
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Converter::MultiMarkdown - multi markdown managed format

=head1 SYNOPSIS

    my $html = $multi_markdown->to_html($input);

=head1 DESCRIPTION

Mojolicious::Plugin::Cms::Converter::MultiMarkdown converts input in multi markdown to html

=head1 METHODS

=head2 name

	my $name = $multi_markdown->name;

Returns the name of the converter: 'multi_markdown'

=head2 to_html

    my $html = $multi_markdown->to_html($input);

The to_html function.

=head1 SEE ALSO

L<Mojolicious::Plugin::Cms>,
L<Mojolicious::Plugin::Cms::Converter>
L<Text::MultiMarkdown>

