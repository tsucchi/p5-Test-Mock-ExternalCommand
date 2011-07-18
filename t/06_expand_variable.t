#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;

my $cmd = "my_dummy_command1";
is( Test::Mock::ExternalCommand::_expand_variable('$cmd', 1), 'my_dummy_command1');

my @commands = (
    'my_dummy_command1',
    'my_dummy_command2',
);
is( Test::Mock::ExternalCommand::_expand_variable('$commands[0]', 1), 'my_dummy_command1');

done_testing();
