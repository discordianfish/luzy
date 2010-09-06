package Mojolicious::Plugin::Cms;
use base 'Mojolicious::Plugin';

use strict;
use warnings;

use DateTime               ();
use I18N::LangTags         ();
use I18N::LangTags::Detect ();

our $VERSION = '0.01';

use Mojolicious::Plugin::Cms::Store::Cache;
use Mojolicious::Plugin::Cms::Store::FileSystem;

my $NS_STORE     = 'Mojolicious::Plugin::Cms::Store';
my $NS_STORE_DEF = "$NS_STORE\::FileSystem";
my $NS_STORE_CAC = "$NS_STORE\::Cache";

__PACKAGE__->attr(app => undef);
__PACKAGE__->attr(cache => sub { $_[0]->cache_class->new($_[0]->cache_options) });
__PACKAGE__->attr(
    cache_class => sub {
        my $class = $_[0]->conf->{cache_class} || 'Cache::FileCache';
        eval "require $class" or die $@;
        $class;
    }
);
__PACKAGE__->attr(cache_options => sub { $_[0]->conf->{cache_options} || {} });
__PACKAGE__->attr(conf          => sub { {} });
__PACKAGE__->attr(default       => sub { $_[0]->conf->{default}       || '_default' });
__PACKAGE__->attr(store => sub { $NS_STORE_DEF->new(cms => $_[0], %{$_[0]->store_options}) });
__PACKAGE__->attr(store_options => sub { $_[0]->conf->{store_options} || {} });
__PACKAGE__->attr(_store => sub { $NS_STORE_CAC->new(cms => $_[0]) });

sub register {
    my ($self, $app, $conf) = @_;

    $self->app($app);
    $self->conf($conf ||= {});

    my $def_language = lc($conf->{default_language} || 'en');

    my $content;
    $app->plugins->add_hook(
        before_dispatch => sub {
            my ($s, $c) = @_;
            undef $content;

            my @languages = I18N::LangTags::implicate_supers(
                I18N::LangTags::Detect->http_accept_langs(
                    scalar $c->req->headers->accept_language
                )
            );

            if (defined(my $p = $c->tx->req->url->path)) {

                $p = $p->append($self->default)
                  if $p->trailing_slash;

                my %seen = ();
                foreach my $l (map {lc} @languages, $def_language, '') {
                    next if $seen{$l}++;
                    next unless $self->_store->exists($p, $l);

                    $content = $self->_store->load($p, $l);
                    $c->stash(cms_content => $content);
                    last;
                }
            }
        }
    );

    $app->routes->add_condition(
        cms => sub {
            my ($route, $tx, $captures, $arg) = @_;
            return ($arg && $content) ? $captures : undef;
        }
    );

    # Helper generation for source methods
    foreach my $method (qw( exists list load save )) {
        $app->renderer->add_helper(
            "cms_$method" => sub {
                my $c = shift;
                return $self->_store->$method(@_);
            }
        );
    }

    # Format heplers
    foreach my $method (['date', '%d.%m.%Y'], ['time', '%T'], ['datetime', '%d.%m.%Y %T']) {
        $app->renderer->add_helper(
            'cms_format_' . $method->[0] => sub {
                my ($c, $epoch, $format) = @_;
                $format ||= $method->[1];
                return DateTime->from_epoch(epoch => $epoch)->strftime($format);
            }
        );
    }

    $app->log->info('Cms loaded');

    # No admin functionality needed shortcut
    return if $conf->{no_admin_route};

    my $r = $conf->{admin_route};
    $r = $app->routes->bridge('/admin')->to(cb => sub {1})
      unless defined $r;

    # Admin routes
    my %defaults = (
        namespace  => 'Mojolicious::Plugin::Cms::Controller',
        controller => 'admin',
        cb         => undef,                                    # overwrite bridges with callbacks
    );
    $r->route('/')->to(%defaults, action => 'list')->name('cms_admin_list');
    $r->route('/edit(*path)', path => qr(/.*))->to(%defaults, action => 'edit')
      ->name('cms_admin_edit');
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Cms - a content management system plugin for mojolicious

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

	#!/usr/bin/env perl
	
	use Mojolicious::Lite;
	
	plugin cms => {
		cache_options => {
			namespace          => 'luzy',
			auto_purge_on_set  => 1,
			default_expires_in => 600,
			cache_root         => app->home->rel_dir('content_cache')
		}
	};
	
	get '/(*everything)' => (cms => 1) => 'cms';
	
	app->start;

	__DATA__
	@@ cms.html.ep
	<html><body>
	<h1><%= $cms_content->title %></h1>
	<%= $cms_content->raw %>
	</body></html>

See luzy.pl for more details.	

=head1 BUGS

Please use githubs issue tracker at
L<http://github.com/esskar/luzy>.

If you want to provide patches, feel free to fork and pull request me.

=head1 AUTHOR, COPYRIGHT AND LICENSE

Copyright (c) 2010 Sascha Kiefer

Released under the MIT license (see MIT-LICENSE) for details.
