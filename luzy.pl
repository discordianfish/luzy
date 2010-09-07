#!/usr/bin/env perl

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/lib";
}

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
<%= $cms_content %>
</body></html>

__END__
