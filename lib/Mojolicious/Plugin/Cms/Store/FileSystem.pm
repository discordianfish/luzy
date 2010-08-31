package Mojolicious::Plugin::Cms::Store::FileSystem;
use base 'Mojolicious::Plugin::Cms::Store';

use strict;
use warnings;

use File::Basename;
use File::Spec  ();
use Path::Class ();
use Mojo::JSON  ();

my $META_START = "<!-- Mojolicious::Plugin::Cms::Content";
my $META_END   = "-->";
my $META_REGEX =
  qr/[\r\n\s]*?$META_START[\r\n\s]*?({.*})[\r\n\s]*?$META_END[\r\n\s]*$/is;

use Mojolicious::Plugin::Cms::Content ();

__PACKAGE__->attr(binmode_layer => ':encoding(utf8)');
__PACKAGE__->attr(directory     => 'content');
__PACKAGE__->attr(extension     => '.cms');
__PACKAGE__->attr(
    make_options => sub { {owner => 'nobody', group => 'nogroup'} });

sub path_to {
    my $self = shift;

    return undef unless my @path = File::Spec->no_upwards(grep {$_} @_);

    my $dir = $self->app->home->rel_dir($self->directory);
    my $path = File::Spec->catfile($dir, @path) . $self->extension;

    return $path;
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

    my $path = $self->path_to(reverse @_);
    return undef unless defined $path;

    my $f = Path::Class::File->new($path);
    my $raw = $f->slurp(iomode => '<' . $self->binmode_layer) || '';
    my $meta;
    if ($raw =~ s/$META_REGEX//) {
        $meta = Mojo::JSON->new->decode($1);
    }
    my $rc = Mojolicious::Plugin::Cms::Content->new(
        raw      => $raw,
        modified => $f->stat->mtime,
        language => $_[-1],
    );
    $rc->update_from($meta) if defined $meta;
    $self->app->log->info('Content loaded.');
    return $rc;
}

sub save {
    my $self    = shift;
    my $content = pop;

    my $path = $self->path_to(reverse @_);
    return undef unless defined $path;

    my $f = Path::Class::File->new($path);
    $f->dir->mkpath($self->make_options);

    if (defined(my $fh = $f->open('w'))) {
        $fh->binmode($self->binmode_layer);
        print $fh $content->raw;
        print $fh "\n$META_START\n"
          . Mojo::JSON->new->encode($content->meta_data)
          . "\n$META_END";
        return $content;
    }

    return undef;
}
1;
