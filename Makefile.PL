#!/usr/bin/env perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Mojolicious::Plugin::Cms',
    AUTHOR        => 'Sascha Kiefer (esskar)',
    VERSION_FROM  => 'lib/Mojolicious/Plugin/Cms.pm',
    ABSTRACT_FROM => 'lib/Mojolicious/Plugin/Cms.pm',
    LICENSE       => 'mit',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Cache::Cache'   => 1.06,
        'DateTime'       => 0.53,
        'Mojolicious'    => 0.9999,
        'Text::Markdown' => 1.000031,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
    clean => {FILES    => 'Mojolicious-Plugin-Cms-* Luzy-*'},
);
