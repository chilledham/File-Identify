#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'File::Identify' ) || print "Bail out!\n";
}

diag( "Testing File::Identify $File::Identify::VERSION, Perl $], $^X" );
