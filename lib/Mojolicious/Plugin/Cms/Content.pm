package Mojolicious::Plugin::Cms::Content;
use base 'Mojo::Base';

use strict;
use warnings;

use overload '""' => sub { shift->html };

use Carp ();
use List::Util qw/first/;
use Mojo::ByteStream 'b';
use Mojo::Loader ();
use Scalar::Util qw/blessed/;

my %OPTIONAL = (
    categories => [],
    tags       => [],
    title      => undef,
    format     => 'markdown',
);
my %REQUIRED = (
    language => undef,
    path     => undef,
    raw      => undef,
);

foreach my $hash (\%OPTIONAL, \%REQUIRED) {
    while (my ($k, $v) = each %$hash) {
        __PACKAGE__->attr($k => 'CODE' eq ref $v ? $v : sub {$v});
    }
}
__PACKAGE__->attr([qw/id _html/]);
__PACKAGE__->attr(modified  => sub {time});
__PACKAGE__->attr(converter => sub { shift->_load_converter });

my %FORMATS = ();

sub _load_converter {
    my $self = shift;
	
	my $format = $self->format;
	return unless $format;

    my $fmt = $FORMATS{lc $format};
    return $fmt if defined $fmt;
		
    my $class = 'Mojolicious::Plugin::Cms::Converter';		
    $class .= '::' . b($format)->camelize;

    my $e = Mojo::Loader->load($class);
    Carp::croak sprintf("Could't load format '%s' (class name: %s)", $format, $class)
      if $e;

    return $FORMATS{lc $format} = $class->new;
}

sub _array_to_string {
    my ($self, $array, $quotes) = @_;
    return join ', ', map { m/\s/ && $quotes ? qq{"$_"} : $_ } sort @$array;
}

sub categories_to_string {
    my $self = shift;
    return $self->_array_to_string($self->categories, @_);
}

sub has_category {
    my ($self, $category) = @_;
    return first { lc($_) eq lc($category) } @{$self->categories};
}

sub has_tag {
    my ($self, $tag) = @_;
    return first { lc($_) eq lc($tag) } @{$self->tags};
}

sub path_parts {
	my $self = shift;
	return [split /\//, $self->path || ''];
}

sub meta_attributes {
    return [sort keys %OPTIONAL];
}

sub meta_data {
    my $self = shift;
    return {map { $_ => $self->$_ } grep { $self->$_ } keys %OPTIONAL};
}

sub required_attributes {
    return [sort keys %REQUIRED];
}

sub tags_to_string {
    my $self = shift;
    return $self->_array_to_string($self->tags, @_);
}

sub html {
    my $self = shift;

    my $html = $self->_html;
    return $html if defined $html;
	
	return $self->raw unless my $converter = $self->converter;

    $html = $converter->to_html($self->raw);
    $self->_html($html);

    return $html;
}

1;
