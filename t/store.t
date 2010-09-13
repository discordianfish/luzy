#!/usr/bin/env perl

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/lib", "$FindBin::Bin/../lib";
}

use strict;
use warnings;

use Mojolicious::Lite;
use Mojolicious::Plugin::Cms;
use Mojolicious::Plugin::Cms::Content;

use Test::More tests => 18;

app->log->level('fatal');

my $cms = Mojolicious::Plugin::Cms->new;
$cms->register(app,
    {   cache_class   => 'Cache::MemoryCache',
        cache_options => {
            namespace          => 'luzy',
            default_expires_in => 600,
        },
        store_options => {directory => app->home->rel_dir('../content')},
    }
);

ok(!$cms->store->exists('/luzy'));
ok($cms->store->exists('/foo'));    # default language
ok($cms->store->exists('/foo', 'en'));
ok(!$cms->store->exists('/foo', 'de'));

my $c1 = Mojolicious::Plugin::Cms::Content->new(
    path     => '/luzy',
    language => 'en'
);


ok($cms->store->save($c1));
ok($cms->store->exists('/luzy'));

ok(my $c2 = $cms->store->load('/luzy'));
ok(my $c3 = $cms->store->load('/luzy', 'en'));
is($c1->id, $c2->id);
is($c1->id, $c3->id);

ok($cms->store->backup($c1));

ok($cms->store->delete($c1));    #only deletes the backup
ok($cms->store->exists('/luzy', 'en'));

ok($cms->store->delete($c1));
ok(!$cms->store->exists('/luzy', 'en'));

ok($cms->store->backup($c2));
ok(!$cms->store->exists('/luzy', 'en'));
ok($cms->store->delete($c2));


