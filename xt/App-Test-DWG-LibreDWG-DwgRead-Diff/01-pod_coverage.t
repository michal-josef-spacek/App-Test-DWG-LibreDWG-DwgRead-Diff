use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('App::Test::DWG::LibreDWG::DwgRead::Diff', 'App::Test::DWG::LibreDWG::DwgRead::Diff is covered.');
