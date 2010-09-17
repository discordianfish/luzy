package Mojolicious::Plugin::Cms::Resolver;
use base 'Mojo::Base';

use Carp;

__PACKAGE__->attr( [qw/cms parser/] );
__PACKAGE__->attr( app      => sub { $_[0]->cms->app } );
__PACKAGE__->attr( bindings => sub { {} } );

sub bind {
    my ( $self, $pattern, $cb ) = @_;    
    $self->bindings->{lc $pattern} = $cb;
}

sub resolve {
    my ( $self, $content ) = @_;

    my $parser = $self->parser;
    croak 'Parser not defined.' unless defined $parser;

    $parser->parse($content);
    while ( my ( $pattern, $callback ) = each %{ $self->bindings } ) {		
        $parser->find($pattern)->each(
            sub {
                my $element = shift;
                $element->replace( $callback->($element) || '' );
            }
        );
    }
    return $parser;
}

1;
