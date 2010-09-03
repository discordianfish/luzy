package Mojolicious::Plugin::Cms::Store::FileSystem;
use base 'Mojolicious::Plugin::Cms::Store';

use strict;
use warnings;

use Carp;
use File::Basename;
use File::Spec  ();
use Mojo::JSON  ();
use Path::Class ();

my $META_START = "<!-- METADATA ";
my $META_END   = " -->";
my $META_REGEX =
  qr/[\r\n\s]*<!--[\r\n\s]*METADATA[\r\n\s]*({.*})[\r\n\s]*-->[\r\n\s]*/is;

use Mojolicious::Plugin::Cms::Content ();

__PACKAGE__->attr(binmode_layer => ':encoding(utf8)');
__PACKAGE__->attr(directory     => 'content');
__PACKAGE__->attr(extension     => '.cms');
__PACKAGE__->attr(
    make_options => sub { {owner => 'nobody', group => 'nogroup'} });

sub backup {
    my $self      = shift;
    my $content   = pop;
    my $timestamp = pop || $content->modified || time;

    my $path = $self->path_to(reverse @_);
    return undef unless defined $path;

    $path .= '.' . $timestamp if $timestamp;

    # unable to save if path exists but is not a file
    return undef if -e $path && !(-f $path);

    $content->id($path) unless defined $content->id;

    my $f = Path::Class::File->new($path);
    $f->dir->mkpath($self->make_options);

    if (defined(my $fh = $f->open('w'))) {
        $fh->binmode($self->binmode_layer);
        print $fh sprintf("%s%s%s\n",
            $META_START, Mojo::JSON->new->encode($content->meta_data),
            $META_END);
        print $fh $content->raw;
        return $content;
    }

    return undef;
}

sub exists {
    my $self = shift;

    my $path = $self->path_to(reverse @_);
    return defined $path ? -f $path : undef;
}

sub _list {
    my ($self, $dir) = @_;

    my $ext = $self->extension;

    my @retval = ();
    while (my $e = $dir->next) {
        next if $e =~ m{^\.\.?};

        if ($e->is_dir) {
            push @retval, $self->_list($e);
        }
        else {
            my ($f, $d, $s) = fileparse($e, $self->extension);
            next unless lc($s || '') eq lc $self->extension;
            push @retval, $d . $f;
        }
    }
    return @retval;
}

sub list {
    my $self = shift;

    my $dir = $self->app->home->rel_dir($self->directory);
    return $self->_list(Path::Class::Dir->new($dir));
}

sub load {
    my $self = shift;

    return $self->restore(@_, 0);
}

sub path_to {
    my $self = shift;

    return undef unless my @path = File::Spec->no_upwards(grep {$_} @_);

    my $dir = $self->app->home->rel_dir($self->directory);
    my $path = File::Spec->catfile($dir, @path) . $self->extension;

    return $path;
}

sub restore {
    my $self      = shift;
    my $timestamp = pop;

    croak "Timestamp not defined." unless defined $timestamp;

    my $path = $self->path_to(reverse @_);
    return undef unless defined $path;

    $path .= '.' . $timestamp if $timestamp;

    return undef unless -f $path && -r $path;

    my $f = Path::Class::File->new($path);
    my $raw = $f->slurp(iomode => '<' . $self->binmode_layer) || '';
    my $meta;
    if ($raw =~ s/$META_REGEX//) {
        $meta = Mojo::JSON->new->decode($1);
    }
    my $rc = Mojolicious::Plugin::Cms::Content->new(
        id       => $path,
        language => $_[-1],
        modified => $timestamp || $f->stat->mtime,
        raw      => $raw,
    );
    $rc->update_from($meta) if defined $meta;
    $self->app->log->info('Content loaded.');
    return $rc;
}

sub save {
    my $self    = shift;
    my $content = pop;

    return $self->backup(@_, undef, $content);
}

1;
