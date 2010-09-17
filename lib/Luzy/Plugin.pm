package Luzy::Plugin;
use base 'Mojolicious::Plugin';

use strict;
use warnings;

__PACKAGE__->attr( [qw/luzy/] );

sub register {
	my ($self, $app, $conf) = @_;
	
	$self->luzy( $conf->{luzy} );	
	$self->initialize( $app, $conf->{plugin_conf} );
}

1;
