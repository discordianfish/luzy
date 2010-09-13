package Mojolicious::Plugin::Cms::Store::FileSystem;
use base 'Mojolicious::Plugin::Cms::Store';

use strict;
use warnings;

use Carp;
use IO::Dir    ();
use IO::File   ();
use File::Path ();
use File::stat ();
use File::Spec ();
use Mojo::JSON ();


my $META_START = "<!-- METADATA ";
my $META_END   = " -->";
my $META_REGEX = qr/[\r\n\s]*<!--[\r\n\s]*METADATA[\r\n\s]*({.*})[\r\n\s]*-->[\r\n\s]*/is;

use Mojolicious::Plugin::Cms::Content ();

__PACKAGE__->attr(binmode_layer => ':encoding(utf8)');
__PACKAGE__->attr(directory     => sub { $_[0]->app->home->rel_dir('content') });
__PACKAGE__->attr(extension     => '.cms');
__PACKAGE__->attr(make_options  => sub { {owner => 'nobody', group => 'nogroup'} });

sub _unique_from_content {
    my ($self, $what) = (shift, shift);

    my $list = $self->list(@_);

    my %data;
    for my $c (@$list) {
        for my $t (@{$c->$what}) {
            my $key = lc $t;
            $data{$key} = $t unless exists $data{$key};
        }
    }

    return [sort values %data];
}

sub all_categories {
    my $self = shift;
    return $self->_unique_from_content(categories => @_);
}

sub all_tags {
    my $self = shift;
    return $self->_unique_from_content(tags => @_);
}

sub backup {
    my ($self, $content, $timestamp) = @_;

    Carp::croak "Path not set."     unless $content->path;
    Carp::croak "Language not set." unless $content->language;

    $timestamp = $content->modified || time
      unless defined $timestamp;

    my $fs_path = $self->path_to($content->path, $content->language);
    return undef unless defined $fs_path;

    $fs_path .= '.' . $timestamp if $timestamp;

    # unable to save if path exists but is not a file
    return undef if -e $fs_path && !(-f $fs_path);

    my ($vol, $dir, undef) = File::Spec->splitpath($fs_path);

    $dir = File::Spec->catdir($vol, $dir);
    File::Path::make_path($dir, $self->make_options)
      unless -d $dir;

    if (defined(my $fh = IO::File->new("> $fs_path"))) {
        $fh->binmode($self->binmode_layer);
        print $fh sprintf("%s%s%s\n",
            $META_START, Mojo::JSON->new->encode($content->meta_data), $META_END);
        print $fh $content->raw || '';
        return $content;
    }

    return undef;
}

sub delete {
    my $self = shift;

    my ($path, $language, $timestamp);

    my $thing = $_[0];
    if (ref $thing && $thing->isa('Mojolicious::Plugin::Cms::Content')) {
        $path     = $thing->path;
        $language = $thing->language;
        return 1 if $self->delete($path, $language, $thing->modified);    # was it a backup?
    }
    else {
        $path      = shift;
        $language  = shift;
        $timestamp = pop;
    }
	
	Carp::croak "Path not set."     unless $path;
    Carp::croak "Language not set." unless $language;

    my $fs_path = $self->path_to($path, $language);
    $fs_path .= '.' . $timestamp if $timestamp;
	
	$self->app->log->debug("Delete '$fs_path'");

    return 0 unless -e $fs_path;

    unlink $fs_path if -f $fs_path;

    return !(-e $fs_path);
}

sub exists {
    my $self     = shift;
    my $path     = shift;
    my $language = shift || $self->cms->default_language;

    my $fs_path = $self->path_to($path, $language);
    $self->app->log->debug("Exists '$fs_path'?");
    return $fs_path ? -f $fs_path : undef;
}

sub _list {
    my ($self, $dir, $language, $ext_re) = @_;

    unless (defined $ext_re) {
        my $ext = $self->extension;
        $ext_re =
          $language
          ? qr{\.\Q$language\E\Q$ext\E$}i
          : qr{\Q$ext\E$}i;
    }

    my @retval = ();
    my $handle = IO::Dir->new($dir);
    while (defined($handle) && defined(my $e = $handle->read)) {
        next if $e =~ m{^\.\.?};

        my $path = File::Spec->catfile($dir, $e);
        if (-d $path) {
            push @retval, $self->_list($path, $language, $ext_re);
        }
        elsif (-f $path && -r $path) {
            next unless $path =~ /$ext_re/;

            my $c = $self->_load_content($path, undef, undef);
            push @retval, $c if defined $c;
        }
    }
    return @retval;
}

sub list {
    my ($self, $language) = @_;

    if ($language) {
        $self->app->log->debug("List content with language $language.");
    }
    else {
        $self->app->log->debug("List content without language.");
    }
    my @list = $self->_list($self->directory, $language);
    my @sorted = sort { $a->id cmp $b->id } @list;
    return \@sorted;
}

# really slow by itself, always use a cache
sub _list_by {
    my $self   = shift;
    my $what   = lc shift;
    my $value  = shift or croak ucfirst($what) . ' parameter not defined';
    my $method = "has_$what";

    my $list = $self->list(@_);

    my $retval = [];
    for my $c (@$list) {
        push @$retval, $c if $c->$method($value);
    }

    return $retval;
}

sub list_by_tag {
    my $self = shift;
    return $self->_list_by(tag => @_);
}

sub list_by_category {
    my $self = shift;
    return $self->_list_by(category => @_);
}

sub load {
    my $self     = shift;
    my $path     = shift;
    my $language = shift || $self->cms->default_language;

    return $self->restore($path, $language, @_, 0);
}

sub path_to {
    my $self     = shift;
    my $language = pop;

    return undef unless my @path = File::Spec->no_upwards(grep {$_} @_);

    my $retval = File::Spec->catfile($self->directory, @path);
    $retval .= ".$language" if $language;
    $retval .= $self->extension;
    return $retval;
}

sub _load_content {
    my ($self, $fs_path, $path, $language, $timestamp) = @_;

    return undef unless -f $fs_path && -r $fs_path;

    my $ext = $self->extension;
    my $dir = $self->directory;
    my $id  = $fs_path;

    # alot of dump hacking here
    $id =~ s{^\Q$dir\E(.*)\Q$ext\E$}{$1}i;
    $id =~ tr{\\}{\/};
    unless ($path) {
        $path = $id;
        croak "Unable to retrieve access path and language from filesystem path."
          unless $path =~ s{(\.([\w\-]+))?$}{}i;
        $language = lc($2 || $self->cms->default_language);
    }

    my $stat = File::stat::stat($fs_path);
    my $content;
    if (defined(my $fh = IO::File->new("< $fs_path"))) {
        $fh->binmode($self->binmode_layer);

        my $raw = do { local $/; <$fh> };
        my $meta;
        if ($raw =~ s{$META_REGEX}{}) {
            $meta = Mojo::JSON->new->decode($1);
        }
        else {
            $self->app->log->debug('No metadata found.');
        }
        $content = Mojolicious::Plugin::Cms::Content->new(
            id       => $id,
            path     => $path,
            language => $language,
            modified => $timestamp || $stat->mtime,
            raw      => $raw,
        );

        while (defined($meta) and (my ($key, $val) = each %$meta)) {
            $content->$key($val)
              if $content->can($key);
        }

        $self->app->log->info('Content loaded.');
    }
    return $content;
}

sub restore {
    my $self      = shift;
    my $path      = shift;
    my $language  = shift;
    my $timestamp = pop;

    croak "Timestamp not defined." unless defined $timestamp;

    my $fs_path = $self->path_to($path, $language);
    return undef unless defined $fs_path;

    $fs_path .= '.' . $timestamp if $timestamp;

    return $self->_load_content($fs_path, $path, $language, $timestamp);
}

sub save {
    my $self    = shift;
    my $content = shift;

    return $self->backup($content, 0);
}

1;
