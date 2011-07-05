#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;

my $m = Test::Mock::ExternalCommand->new();

$m->set_command( "my_dummy_command1", "", 0  );
$m->set_command( "my_dummy_command2", "", 1  );
$m->set_command( "my_dummy_command3", "", 1  );

system("my_dummy_command1 -x -y");
system("my_dummy_command2 --some-option");
`my_dummy_command3 -a -b`;

my $history_expected = [
    ["my_dummy_command1", "-x", "-y"],
    ["my_dummy_command2", "--some-option"],
    ["my_dummy_command3", "-a", "-b"],
];

is_deeply( [$m->history], $history_expected );

done_testing();
