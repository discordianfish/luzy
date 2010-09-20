#!/usr/bin/env perl

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/lib", "$FindBin::Bin/../lib";
}

use Mojolicious::Lite;
use Test::Mojo;
use Test::More tests => 5;

use Mojo::Transaction::HTTP;
use Mojolicious::Controller;
use Mojolicious::Plugin::Cms::Resolver::DOM;

app->log->level('debug');

my $controller = Mojolicious::Controller->new(app => app, tx => Mojo::Transaction::HTTP->new);
$controller->stash(title => 'Hello resolver!');
my $resolver = Mojolicious::Plugin::Cms::Resolver::DOM->new(app => app, template_subdir => '');
$resolver->bind(span => sub { $_[1]->stash(foo => 'bar') });
$resolver->bind('div[id="foo"]', template => 'foo');
$resolver->bind('div[id="bar"]', sub { $_[1]->stash(bar => 'foo') }, template => 'bar');

like($resolver->resolve($controller, '<title runat="server"><%= $title %></title>'),
    qr~<title>Hello resolver!</title>~);
like($resolver->resolve($controller, '<span runat="server"><%= $foo %></span>'),
    qr~<span>bar</span>~);
like($resolver->resolve($controller, '<div id="foo" />'),                qr~<div>test</div>~);
like($resolver->resolve($controller, '<div id="bar" />'),                qr~<div>foo</div>~);
like($resolver->resolve($controller, '<div id="foo" template="bar" />'), qr~<div>foo</div>~);


__DATA__
@@ foo.html.ep
<div>test</div>

@@ bar.html.ep
<div><%= $bar %></div>

__END__
