package Mojolicious::Plugin::Cms;
use base 'Mojolicious::Plugin';

use strict;
use warnings;

use DateTime               ();
use Cache::FileCache       ();
use I18N::LangTags         ();
use I18N::LangTags::Detect ();

our $VERSION = '0.011';

use Mojo::DOM;
use Mojo::Loader;
use Mojolicious::Plugin::Cms::Resolver::DOM;
use Mojolicious::Plugin::Cms::Store::Cache;
use Mojolicious::Plugin::Cms::Store::FileSystem;

__PACKAGE__->attr(app            => undef);
__PACKAGE__->attr(cache          => sub { $_[0]->cache_class->new($_[0]->cache_options) });
__PACKAGE__->attr(cache_class    => sub { $_[0]->conf->{cache_class} || 'Cache::FileCache' });
__PACKAGE__->attr(cache_options  => sub { $_[0]->conf->{cache_options} || {} });
__PACKAGE__->attr(condition_name => sub { $_[0]->conf->{condition_name} || 'cms' });
__PACKAGE__->attr(conf             => sub { {} });
__PACKAGE__->attr(default_format   => sub { lc($_[0]->conf->{default_format} || 'markdown') });
__PACKAGE__->attr(default_language => sub { lc($_[0]->conf->{default_language} || 'en') });
__PACKAGE__->attr(index            => sub { $_[0]->conf->{index} || 'index' });
__PACKAGE__->attr(
    resolver => sub {
        $_[0]->conf->{resolver}
          || Mojolicious::Plugin::Cms::Resolver::DOM->new(cms => $_[0]);
    }
);
__PACKAGE__->attr(
    store => sub {
        Mojolicious::Plugin::Cms::Store::FileSystem->new(
            cms => $_[0],
            %{$_[0]->store_options}
        );
    }
);
__PACKAGE__->attr(store_options => sub { $_[0]->conf->{store_options} || {} });
__PACKAGE__->attr(
    _store => sub {
        $ENV{MOJO_RELOAD}
          ? $_[0]->store
          : Mojolicious::Plugin::Cms::Store::Cache->new(cms => $_[0]);
    }
);

sub _add_binding {
	my ($self) = @_;
	
	# Predefined resolver bindings
    $self->resolver->bind(time => sub {time});	
}

sub register {
    my ($self, $app, $conf) = @_;

    $self->app($app);
    $self->conf($conf ||= {});

    my $def_language = $self->default_language;

    my $content;
    $app->plugins->add_hook(
        before_dispatch => sub {
            my ($s, $c) = @_;						
			
            undef $content;

            # eperimental: return when static content is to be served
            my $static_file =
              File::Spec->catfile($self->app->static->root, $c->tx->req->url->path);
            my $is_static = (-e $static_file && -f $static_file) || 0;
            return if $is_static;

            # Empty values
            $c->stash(cms_language => undef);
            $c->stash(cms_content  => undef);

            my @languages = I18N::LangTags::implicate_supers(
                I18N::LangTags::Detect->http_accept_langs(
                    scalar $c->req->headers->accept_language
                )
            );

            # clone, dont want to modify original path
            if (defined(my $p = $c->access_path)) {
                my %seen = ();
                foreach my $l (map {lc} @languages, $def_language) {
                    next if $seen{$l}++;
                    next unless $self->_store->exists($p, $l);

                    $content = $self->_store->load($p, $l);

                    $c->stash(cms_language => $l);
                    $c->stash(cms_content  => $content);
                    last;
                }
            }
        }
    );

    my $condition_name = $self->condition_name;
    $app->routes->add_condition(
        $condition_name => sub {
            my ($route, $tx, $captures, $arg) = @_;
            return ($arg && $content) ? $captures : undef;
        }
    );

    $app->helper(
        access_path => sub {
            my $c = shift;
            my $p = shift;
            $p = $p ? Mojo::Path->new($p) : $c->tx->req->url->path->clone;

            $p = $p->append($self->index)
              if $p->trailing_slash && 1 == length $p;

            return $p;
        }
    );
    $app->helper(resolve => sub { $self->resolver->resolve(@_) });
    
    # Helper generation for source methods
    for my $m (
        qw/all_tags all_categories backup delete exists
        list list_by_category list_by_tag load restore save/
      )
    {
        $app->helper(
            "cms_$m" => sub {
                my $c = shift;
                return $self->_store->$m(@_);
            }
        );
    }
    for my $m (qw/default_format default_language/) {
        $app->helper("cms_$m" => sub { return $self->$m });
    }

    # Format helpers
    for my $method (['date', '%d.%m.%Y'], ['time', '%T'], ['datetime', '%d.%m.%Y %T']) {
        $app->helper(
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
    $r->route('/create')->to(%defaults, action => 'edit')->name('cms_admin_create');
    $r->route('/edit(*path)', path => qr(/?.+))->to(%defaults, action => 'edit')
      ->name('cms_admin_edit');

    $app->log->info('Admin routes configured');
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
