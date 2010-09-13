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

use Test::More tests => 26;

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

ok(!$cms->store->exists('/luzy'), '/luzy does not exist yet.');
ok($cms->store->exists('/foo'),   '/foo exists (language: default).');    # default language
ok($cms->store->exists('/foo', 'en'), '/foo exists (language: en).');
ok(!$cms->store->exists('/foo', 'de'), '/foo does not exist (language: de).');

my $c1 = Mojolicious::Plugin::Cms::Content->new(
    path     => '/luzy',
    language => 'en'
);


ok($cms->store->save($c1),       '/luzy saved.');
ok($cms->store->exists('/luzy'), '/luzy exists.');

ok(my $c2 = $cms->store->load('/luzy'), '/luzy loaded. (language: default)');
ok(my $c3 = $cms->store->load('/luzy', 'en'), '/luzy loaded. (language: en)');
is($c1->id, $c2->id, '/luzy is same as /luzy. (language: default)');
is($c1->id, $c3->id, '/luzy is same as /luzy. (language: en)');

is(@{$cms->store->revisions($c1)}, 0, '/luzy has 0 revsions');
ok($cms->store->backup($c1), '/luzy backup ok');
is(@{$cms->store->revisions($c1)}, 1, '/luzy has 1 revisions now');
ok($cms->store->delete($c1->path, $c1->language, $c1->modified), '/luzy backup deleted.');
is(@{$cms->store->revisions($c1)}, 0, '/luzy has 0 revisions');
ok($cms->store->exists('/luzy', 'en'), '/luzy still exists.');

ok($cms->store->delete($c1), '/luzy deleted');
ok(!$cms->store->exists('/luzy', 'en'), '/luzy does no longer exists.');

ok($cms->store->backup($c2), '/luzy backup ok.');
ok(!$cms->store->exists('/luzy', 'en'), '/luzy does not exists on the filesystem.');
is(@{$cms->store->revisions($c3)}, 1, 'but /luzy has 1 revisions now');
ok($cms->store->save($c3), '/luzy saved.');
ok($cms->store->exists('/luzy', 'en'), '/luzy does exists on the filesystem');
ok($cms->store->delete($c2), 'Delete everything.');
ok(!$cms->store->exists('/luzy', 'en'), '/luzy does not exists.');
is(@{$cms->store->revisions($c1)}, 0, '/luzy has 0 revisions');

