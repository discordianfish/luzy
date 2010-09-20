package Mojolicious::Plugin::Cms::Resolver;
use base 'Mojo::Base';

use strict;
use warnings;

use Carp;
use File::Spec ();

__PACKAGE__->attr([qw/cms parser no_default_binding/]);
__PACKAGE__->attr(app      => sub { $_[0]->cms->app });
__PACKAGE__->attr(bindings => sub { {} });
__PACKAGE__->attr(template_subdir => 'partials');

sub bind {
    my $self    = shift;
    my $pattern = shift;

    my $cb;
    $cb = shift if 'CODE' eq ref $_[0];
    my %args = ref $_[0] ? %{$_[0]} : @_;

    $self->bindings->{lc $pattern} = {%args, cb => $cb,};
}

sub _resolve_entity {
    my ($self, $bind, $controller, $entity) = @_;

    my $runat = delete $entity->attrs->{runat} || '';
    my $template = delete $entity->attrs->{template} || $bind->{template} || undef;

    $template = File::Spec->catfile($self->template_subdir, $template)
      if $template && $self->template_subdir;

    my $cb = $bind->{cb};

    my $output;
    $output = $cb->($entity, $controller) if 'CODE' eq ref $cb;
    if ($template) {
        $output = $controller->render_partial(template => $template)->to_string;
    }
    elsif (lc $runat eq 'server') {
        my $xml = $entity->to_xml;

        # ugly
        $xml =~ s{(<\%=.*)\%\s+/>}{$1%>}g;
        $output = $controller->render_partial(inline => $xml)->to_string;
    }
    $entity->replace($output || '');
}

sub resolve {
    my ($self, $controller, $content) = @_;

    my $parser = $self->parser;
    croak 'Parser not defined.' unless defined $parser;

    $parser->parse($content);
    while (my ($pattern, $bind) = each %{$self->bindings}) {
        $parser->find($pattern)->each(sub { $self->_resolve_entity($bind, $controller, @_) });
    }
    $parser->find('*[runat="server"]')->each(sub { $self->_resolve_entity({}, $controller, @_) })
      unless $self->no_default_binding;

    return $parser->to_xml;
}


1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms::Resolver - Adds dynamic spice to your CMS content

=head1 SYNOPSIS

    use Mojolicious::Plugin::Cms::Resolver;

	my $controller; # some Mojolicious::Controller 	
	$controler->stash( title => 'Hello resolver!' );
	
    my $resolver = Mojolicious::Plugin::Cms::Resolver->new;
	my $resolved = $resolver->resolve( $controller, '<title runat="server"><%= $title %></title>');
		
	$resolver->bind(span => sub { $_[1]->stash( foo => 'bar' ) });
	$resolved = $resolver->resolve( $controller, '<span runat="server"><%= $foo %></span>');
	
=head1 DESCRIPTION

Using the resolver your able to add more dynamic features to your CMS content.
CMS content by it self is not dynamic, you write your text or markup, that get's translated to (X)HTML, 
and is served to the web client. You dont't have any dynamic features you have when using templates - 
and you do not want that, because content writers usually don't have any knowledge about writing code.
Use the resolver to spice up your content.

=head1 EXAMPLES

=head2 Current time

One simple example is too insert the current time. So you define your foo.en.cms and add the following 
markdown text.

	Current Time
	============
	
	This content was served at: <time />

On the server side you add the following to your resolver

	$resolver->bind(time => sub { time });
	
When the content is rendered, the <time /> tag will be replaced with the value of time.
HINT: The resolver already defines this binding, so you do not have to do it again.

=head2 Twitter search

Display twitter keyword results is easy. Write some markdown

	Twitter results for Mojolicious
	===============================
	
	<twitter serach="mojolicious" />
	
A simple resolver code looks like this

	use Mojo::Client;
	my $client = Mojo::Client->new;
	$resolver->bind(twitter => sub {
		my $entity = shift;
		
		return 'No search key defined' unless my $search = $entity->attrs->{search};
		
		my $retval = '';
		my $results = $client->get("http://search.twitter.com/search.json?q=$search")->res->json->{results};
		foreach my $r (@$results) {		
			$retval .= $r->{from_user} . ' wrote:' . $r->{text} . "<br />\n";
		}
		
		return $retval;
	});

=cut

