#!/usr/bin/env perl

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/lib", "$FindBin::Bin/../lib";
}

use Mojolicious::Lite;
use Test::Mojo;
use Test::More tests => 4;

app->log->level('error');

# Content management configuration
plugin cms => {
    cache_class   => 'Cache::MemoryCache',
    cache_options => {
        namespace          => 'luzy',
        default_expires_in => 600,
    },
    store_options => {directory => app->home->rel_dir('../content')},
};

get '/(*everything)' => (cms => 1) => 'cms';

# Go for it!
my $t = Test::Mojo->new;

# Pages
$t->get_ok('/foo')->content_like(qr{this is /foo});
$t->get_ok('/foo/uhu')->content_like(qr{this is /foo/uhu});


__DATA__
@@ cms.html.ep
<%== $cms_content->raw %>

__END__
