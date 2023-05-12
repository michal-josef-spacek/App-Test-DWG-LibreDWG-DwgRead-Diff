use strict;
use warnings;

use App::Test::DWG::LibreDWG::DwgRead::Diff;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = App::Test::DWG::LibreDWG::DwgRead::Diff->new;
isa_ok($obj, 'App::Test::DWG::LibreDWG::DwgRead::Diff');
