#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;
use File::Spec::Functions qw(catdir curdir catfile);

my $m = Test::Mock::ExternalCommand->new();

$m->set_command( "my_dummy_command1", "AAA\n", 0  );

my $my_dummy_command1_output = `my_dummy_command1`;
is( $my_dummy_command1_output, "AAA\n" );
my $ret1 = system("my_dummy_command1");
is( $ret1>>8, 0);

done_testing();
