#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Mock::ExternalCommand;
use File::Spec::Functions qw(tmpdir);

my $m = Test::Mock::ExternalCommand->new();
ok( defined $m->script_dir );
my $tmpdir = tmpdir();
like( $m->script_dir, qr/^$tmpdir/);

done_testing();
