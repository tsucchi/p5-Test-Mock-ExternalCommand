#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;
use File::Spec::Functions qw(catdir curdir catfile);

my $tmp_dir = catdir( curdir(), "tmp");
my $m = Test::Mock::ExternalCommand->new(
    script_dir => $tmp_dir,
);

$m->set_command( "my_dummy_command1", "", 0  );
$m->set_command( "my_dummy_command2", "", 1  );

system("my_dummy_command1 -x -y");
system("my_dummy_command2 --some-option");

my $history_expected = [
    ["my_dummy_command1", "-x", "-y"],
    ["my_dummy_command2", "--some-option"],
];

is_deeply( [$m->history], $history_expected );

done_testing();
