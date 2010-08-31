package Mojolicious::Plugin::Cms;
use base 'Mojolicious::Plugin';

use strict;
use warnings;

use I18N::LangTags;
use I18N::LangTags::Detect;

our $VERSION = '0.01';

use Cache::FileCache;

use Mojolicious::Plugin::Cms::Store::Cache;
use Mojolicious::Plugin::Cms::Store::FileSystem;

my $NS_STORE     = 'Mojolicious::Plugin::Cms::Store';
my $NS_STORE_DEF = "$NS_STORE\::FileSystem";
my $NS_STORE_CAC = "$NS_STORE\::Cache";

__PACKAGE__->attr(app => undef);
__PACKAGE__->attr(
    cache => sub { Cache::FileCache->new($_[0]->conf->{cache_options}) });
__PACKAGE__->attr(conf => sub { {} });
__PACKAGE__->attr(store => sub { $NS_STORE_DEF->new(app => $_[0]->app) });
__PACKAGE__->attr(
    _store => sub { $NS_STORE_CAC->new(app => $_[0]->app, cms => $_[0]) });
__PACKAGE__->attr(default => sub { $_[0]->conf->{default} || '_default' });

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

            #return ($arg) ? $captures : undef;
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

    $app->log->info('Cms loaded');
}

1;
