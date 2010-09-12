package Mojolicious::Plugin::Cms::Controller::Admin;
use base 'Mojolicious::Plugin::Cms::Controller';

use strict;
use warnings;

use Mojo::Path;
use Mojolicious::Plugin::Cms::Content;

sub _parse_csv {
    my $self   = shift;
    my $string = shift;

    return [] unless $string;
    
    my @tags;
    my %seen;

    # In this regexp, the actual content of the tag is in the last
    # paren-group which matches in each alternative.
    # Thus it can be accessed as $+
    # See Text::Tags::Parser
    while (
        $string =~ m{\G [\s,]* (?:
                        (") ([^"]*) (?: " | $) |      # double-quoted string
                        (') ([^']*) (?: ' | $) |      # single-quoted string
                        ([^\s,]+)                     # other 
		     )}gx
      )
    {
        my $tag = $+;
        my $is_quoted = $1 || $3;

        # shed explictly quoted empty strings
        next unless length $tag;

        $tag =~ s/^\s+//;
        $tag =~ s/\s+$//;
        $tag =~ s/\s+/ /g;

        # Tags should be unique, but in the right order
        push @tags, $tag unless $seen{$tag}++;
    }

    return \@tags;
}

sub _preview {
}

sub _save {
    my $self = shift;

    my $stash = $self->stash;

    my %required;
    for my $r (@{Mojolicious::Plugin::Cms::Content->required_attributes}, qw/permalink title/) {
        my $value = $self->param($r);
        unless ($value || $r eq 'path') {

            # Error handling
            $stash->{errors}++;
            $stash->{"error_$r"}++;
        }
        $required{$r} = $value;
    }

    my $new = !$required{path};

    $required{path} ||= $required{permalink};
	$required{$_} = $self->access_path( $required{$_} )
		foreach (qw/path permalink/);
	
    $self->app->log->debug("Loading content $required{path}, $required{language} ...");

    my $content = $self->cms_load($required{path}, $required{language});
    if (defined($content)) {
        if ($new && !$self->param('force')) {

            # More error handling
            $stash->{errors}++;
            $stash->{error_permalink_exists}++;
            return;
        }
    }
    else {
        $content = Mojolicious::Plugin::Cms::Content->new;
    }

    # Let the user fix the errors
    return if $self->stash('errors');

    # Everything normal.
    my $overwrite = !$new && lc $required{permalink} eq lc $required{path};
    if ($overwrite) {
        $self->cms_backup($content);
    }
    elsif (!$new) {
        $self->cms_delete($content->path, $content->language);
    }

    while (my ($key, $val) = each %required) {
        $content->$key($val)
          if $content->can($key);
    }
    $content->modified(time);

    $content->tags($self->_parse_csv($self->param('tags')));
    $content->categories($self->_parse_csv($self->param('categories')));

    # save it now
    $content->path($required{permalink});

    $self->app->log->debug("About to save ...");
    $self->cms_save($content);

    $self->redirect_to('cms_admin_list');
}

sub edit {
    my $self = shift;

    return 1 unless $self->req->method eq 'POST';

    my $submit = lc $self->param('submit');

    return $self->redirect_to('cms_admin_list') if $submit eq 'cancel';
    return $self->_preview(@_)                  if $submit eq 'preview';
    return $self->_save(@_)                     if $submit eq 'save';
}

sub list {
    my $self = shift;

    return 1 unless $self->req->method eq 'POST';

    my $submit = lc $self->param('submit');
    if ($submit eq 'create') {
        $self->redirect_to('cms_admin_create');
        return;
    }
}

1;
