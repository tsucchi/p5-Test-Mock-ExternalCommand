#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;

my $m = Test::Mock::ExternalCommand->new();
ok(defined $m);

$m->set_command( "my_dummy_command1", "AAA\n", 0  );
$m->set_command( "my_dummy_command2", "BBB\n", 1  );
$m->set_command_by_coderef( "my_dummy_command3", sub { return 0 });
$m->set_command_by_coderef( "my_dummy_command4", sub { return 1 });
$m->set_command_by_coderef( "my_dummy_command5", sub { return "CCC\n" });
$m->set_command_by_coderef( "my_dummy_command6", sub { return "DDD\n" });


my $my_dummy_command1_output = `my_dummy_command1`;
is( $my_dummy_command1_output, "AAA\n" );

my $my_dummy_command2_output = `my_dummy_command2`;
is( $my_dummy_command2_output, "BBB\n" );

my $ret1 = system("my_dummy_command1");
is( $ret1>>8, 0);

my $ret2 = system("my_dummy_command2");
is( $ret2>>8, 1);

my $ret3 = system("my_dummy_command3");
is( $ret3>>8, 0);

my $ret4 = system("my_dummy_command4");
is( $ret4>>8, 1);

is( `my_dummy_command5`, "CCC\n" );
is( `my_dummy_command6`, "DDD\n" );

done_testing();
