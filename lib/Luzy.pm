package Luzy;
use base 'Mojolicious::Plugin::Cms';

use strict;
use warnings;

__PACKAGE__->attr(auto_route => sub { shift->conf->{auto_route} || {} });

sub register {
    my ($self, $app, $conf) = @_;

    my $plugins            = delete $conf->{plugins}            || [];
    my $plugins_namespaces = delete $conf->{plugins_namespaces} || [];


    # prepare plugins
    unshift @{$app->plugins->namespaces}, @$plugins_namespaces, 'Luzy::Plugin';

    # register the CMS
    my $rc = $self->SUPER::register($app, $conf);

    # load plugins
    my %seen;
    foreach (@$plugins, qw/iso_639/) {
        my $plugin = ref($_) ? $_ : [$_];
        next if $seen{$plugin->[0]}++;
        $app->plugin($plugin->[0], {luzy => $self, plugin_conf => $plugin->[1]});
    }

    return $rc if $conf->{no_auto_route};

    my $route_name  = $self->auto_route->{name}  || 'cms';
    my $route_match = $self->auto_route->{match} || qr(.*);

    my $routes = $app->routes;
    $routes->route('/(*everything)', {everything => $route_match})
      ->over($self->condition_name => 1)->to(namespace => '')->name($route_name);

    return $rc;
}

1;
