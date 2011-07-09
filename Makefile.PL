use inc::Module::Install;
name 'Test-Mock-ExternalCommand';
all_from 'lib/Test/Mock/ExternalCommand.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requres  'Capture::Tiny';

auto_set_repository;
auto_include;
WriteAll;
