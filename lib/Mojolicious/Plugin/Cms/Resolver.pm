package Mojolicious::Plugin::Cms::Resolver;
use base 'Mojo::Base';

use Carp;

__PACKAGE__->attr([qw/cms parser/]);
__PACKAGE__->attr(app         => sub { $_[0]->cms->app });
__PACKAGE__->attr(definitions => sub { {} });

sub define {
    my ($self, $name, $cb) = @_;
    $self->definitions->{lc $name} = $cb;
}

sub resolve {
    my ($self, $content) = @_;

    my $parser = $self->parser;
    croak 'Parser not defined.' unless defined $parser;

    $parser->parse($content);
    return unless my $plugins = $parser->find('plugin');

    $plugins->each(
        sub {
            my $plugin = shift;
            my $attrs  = $plugin->attrs;

            return $self->app->log->debug('Found plugin without a name')
              unless my $name = $attrs->{name};

            my $cb = $self->definitions->{lc $name};
            $self->app->log->debug('Undefined plugin: ' . $name)
              unless $cb;

            $plugin->replace($cb ? $cb->() : '');
        }
    );
    return $parser;
}

1;
