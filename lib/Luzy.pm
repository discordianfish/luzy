package Luzy;
use base 'Mojolicious::Plugin::Cms';

use strict;
use warnings;

sub register {
    my ($self, $app, $conf) = @_;

    unshift @{$app->plugins->namespaces}, 'Luzy::Plugin';

    my $plugins = delete $conf->{plugins} || [];
    $self->SUPER::register($app, $conf);

    foreach my $plugin (@$plugins) {
        if (ref $plugin) {
            $app->plugin(@$plugin);
        }
        else {
            $app->plugin($plugin);
        }
    }
}

1;
