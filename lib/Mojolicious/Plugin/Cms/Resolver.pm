package Mojolicious::Plugin::Cms::Resolver;
use base 'Mojo::Base';

use strict;
use warnings;

use Carp;
use Encode;
use File::Spec;

__PACKAGE__->attr([qw/cms parser/]);
__PACKAGE__->attr(app      => sub { $_[0]->cms->app });
__PACKAGE__->attr(bindings => sub { {} });
__PACKAGE__->attr(template_subdir => 'resolver');

sub bind {
    my ($self, $pattern, $cb, @args) = @_;
    my %args = ref $args[0] ? %{$args[0]} : @args;
    $self->bindings->{lc $pattern} = {%args, cb => $cb,};
}

sub resolve {
    my ($self, $c, $content) = @_;

    my $parser = $self->parser;
    croak 'Parser not defined.' unless defined $parser;

    my $path = $self->template_subdir || '';

    $parser->parse($content);
    while (my ($pattern, $bind) = each %{$self->bindings}) {
        $parser->find($pattern)->each(
            sub {
                my $element = shift;

                my $template;
                $template = File::Spec->catfile($path, $bind->{name})
                  if $bind->{name};
                my $output = $bind->{cb}->($element, $c);
                $output = $c->render_partial(template => $template)->to_string
                  if $template;
                $element->replace($output || '');
            }
        );
    }

    return $parser;
}

1;
