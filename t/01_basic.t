#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;
use File::Spec::Functions qw(catdir curdir catfile);

my $script_dir = catdir( curdir(), "tmp");
my $m = Test::Mock::ExternalCommand->new( script_dir => $script_dir );
ok(defined $m);

$m->set_command( "my_dummy_command1", "AAA\n", 0  );
$m->set_command( "my_dummy_command2", "BBB\n", 1  );

ok( -d $script_dir );
ok( -x catfile( $script_dir, "my_dummy_command1" ) );
ok( -x catfile( $script_dir, "my_dummy_command2" ) );

my $my_dummy_command1_output = `my_dummy_command1`;
is( $my_dummy_command1_output, "AAA\n" );

my $my_dummy_command2_output = `my_dummy_command2`;
is( $my_dummy_command2_output, "BBB\n" );

my $ret1 = system("my_dummy_command1");
is( $ret1>>8, 0);

my $ret2 = system("my_dummy_command2");
is( $ret2>>8, 1);

$m = undef;#call DESTROY
ok( !-d $script_dir );
done_testing();
