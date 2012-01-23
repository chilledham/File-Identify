use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'File::Identify',
    license             => 'perl',
    dist_author         => q{collin seaton <collinseaton@gmail.com>},
    dist_version_from   => 'lib/File/Identify.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'File-Identify-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
