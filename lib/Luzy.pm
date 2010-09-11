package Luzy;
use base 'Mojolicious::Plugin::Cms';

use strict;
use warnings;

sub register {
    my ($self, $app, $conf) = @_;
    
	# prepare plugins
	unshift @{$app->plugins->namespaces}, 'Luzy::Plugin';
	
    my $plugins = delete $conf->{plugins} || [];
		
		
	# register the CMS
    $self->SUPER::register($app, $conf);

	# load plugins	
	my %seen;
	foreach (@$plugins, qw/iso_639/) {
		my $plugin = ref($_) ? $_ : [$_];
		next if $seen{$plugin->[0]}++;
		$app->plugin(@$plugin);
	}
}

1;
