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
        'Mojolicious'  => 0.9999,
        'Cache::Cache' => 1.06,
        'DateTime'     => 0.61,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
    clean => {FILES    => 'Mojolicious-Plugin-Cms-*'},
);
