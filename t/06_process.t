#!/usr/bin/perl -w

# Create a new database when opening a file that doesn't exist

use strict;
use lib ();
use UNIVERSAL 'isa';
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import('blib', 'lib');
	}
}

use Test::More tests => 15;



# Create the test metrics database, and fill it
my $test_dir     = 't.data';
my $test_dir_abs = rel2abs('t.data');
my $test_create  = catfile( $test_dir, 'create.sqlite' );
ok( -d $test_dir, 'Test directory exists'                 );
ok( -r $test_dir, 'Test directory read permissions ok'    );
ok( -w $test_dir, 'Test directory write permissions ok'   );
ok( -x $test_dir, 'Test directory enter permissions ok'   );
ok( ! -f $test_create, 'Test database does not exist yet' );
END { unlink $test_create if -f $test_create; }
use_ok( 'Perl::Metrics', $test_create );
Perl::Metrics->process_directory( $test_dir_abs );





#####################################################################
# Manually create a plugin object.

my @metrics = Perl::Metrics::Metric->retrieve_all(
	package => 'Perl::Metrics::Plugin::Core',
	{ order_by => 'hex_id, package, name' }
	);
is( scalar(@metrics), 8, '4 metrics on 3 files makes 8 metric objects, correctly' );

my @vals = ( 0, 0, 8, 15, 17, 1, 12, 25 );
foreach ( @metrics ) {
	my $hex_id = $_->hex_id;
	my $name   = $_->name;
	my $value  = $_->value;
	is( $value, shift(@vals), "$hex_id.$name: Value '$value' matches expected" );
}
