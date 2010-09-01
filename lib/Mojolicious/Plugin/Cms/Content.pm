package Mojolicious::Plugin::Cms::Content;
use base 'Mojo::Base';

use overload '""' => sub { shift->raw };

use warnings;
use strict;

use Scalar::Util qw/blessed/;

my @META_ATTRS = qw/title/;
my @DATA_ATTRS = qw/language path raw/;

__PACKAGE__->attr([@DATA_ATTRS, @META_ATTRS]);
__PACKAGE__->attr(modified => sub {time});

sub meta_data {
    my $self = shift;
	
	return {map { $_ => $self->$_ || '' } @META_ATTRS};
}

sub save_to {
    my ($self, $store) = @_;
    return $store->save($self->path, $self->language, $self);
}

sub update_from {
    my ($self, $req) = @_;

    my $getter =
      blessed($req)
      ? sub { $req->param($_[0]) }
      : sub { exists $req->{$_[0]} ? $req->{$_[0]} : undef };
    foreach my $p (@DATA_ATTRS, @META_ATTRS) {
        my $val = $getter->($p);
        $self->$p($val) if defined $val;
    }

    return $self;
}

1;
