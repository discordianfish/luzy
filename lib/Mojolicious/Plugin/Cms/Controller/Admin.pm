package Mojolicious::Plugin::Cms::Controller::Admin;
use base 'Mojolicious::Plugin::Cms::Controller';

use strict;
use warnings;

use Mojo::Path;
use Mojolicious::Plugin::Cms::Content;

# (c)2008 Kim Anthony Gentes - FREE TO USE ANYWHERE.
my $CSV_RE = qr{^(("(?:[^"]|"")*"|[^,]*)(,("(?:[^"]|"")*"|[^,]*))*)$};

sub _parse_csv {
    my $self = shift;

    my @values;
    @values = ($_[0] =~ m/$CSV_RE/g) if $_[0];
    return \@values;
}

sub edit {
    my $self = shift;

    return 1 unless $self->req->method eq 'POST';

    my %required;
    for my $r (@{Mojolicious::Plugin::Cms::Content->required_attributes}, qw/permalink/) {
        my $value = $self->param($r);
        unless ($value) {
			next if $r eq 'path';
		
            # TODO
            return;
        }
        $required{$r} = $value;
    }
	
	$required{path} ||= $required{permalink};	
	$self->app->log->debug("Loading content $required{path}, $required{language} ...");
	
	my $new = 0;
    my $content = $self->cms_load($required{path}, $required{language});
	unless(defined $content) {
		$content = Mojolicious::Plugin::Cms::Content->new;
		$new = 1;
	}
			
	my $overwrite = !$new && lc $required{permalink} eq lc $required{path};
	if($overwrite) {
		$self->cms_backup($content);
	} elsif(!$new) {
		$self->cms_delete($content->path, $content->language);
	}
		
	while (my ($key, $val) = each %required) {
        $content->$key($val)
          if $content->can($key);
    }
	$content->modified( time );

    $content->tags($self->_parse_csv($self->param('tags')));
    $content->categories($self->_parse_csv($self->param('categories')));
		    
	# save it now
    $content->path($required{permalink});
	
	$self->app->log->debug("About to save ...");
    $self->cms_save($content);
}

sub list { 
	my $self = shift;
	
	return 1 unless $self->req->method eq 'POST';
	
	my $submit = lc $self->param('submit');
	if($submit eq 'create') {
		$self->redirect_to('cms_admin_create');
		return;
	}
}

1;
