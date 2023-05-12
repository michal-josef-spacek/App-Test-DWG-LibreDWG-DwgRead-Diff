package App::Test::DWG::LibreDWG::DwgRead::Diff;

use strict;
use warnings;

use Capture::Tiny qw(capture);
use File::Copy;
use File::Path qw(mkpath);
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);
use Getopt::Std;
use IO::Barf qw(barf);
use Readonly;

Readonly::Scalar our $DR => 'dwgread';

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Object.
	return $self;
}

# Run.
sub run {
	my $self = shift;

	# Process arguments.
	$self->{'_opts'} = {
		'd' => undef,
		'h' => 0,
		'v' => 9,
	};
	if (! getopts('d:hv:', $self->{'_opts'}) || @ARGV < 2
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-d test_dir] [-h] [-v level] [--version] dwg_file1 dwg_file2\n";
		print STDERR "\t-d test_dir\tTest directory (default is directory in system tmp).\n";
		print STDERR "\t-h\t\tPrint help.\n";
		print STDERR "\t-v level\tVerbosity level (default 9, min 0, max 9).\n";
		print STDERR "\t--version\tPrint version.\n";
		print STDERR "\tdwg_file1\tFirst DWG file to test.\n";
		print STDERR "\tdwg_file2\tSecond DWG file to test.\n";
		return 1;
	}
	$self->{'_dwg_file1'} = shift @ARGV;
	$self->{'_dwg_file2'} = shift @ARGV;

	if ($self->{'_opts'}->{'v'} == 0) {
		warn "Verbosity level 0 hasn't detection of ERRORs.\n";
	}

	my $tmp_dir = $self->{'_opts'}->{'d'};
	if (defined $tmp_dir && ! -d $tmp_dir) {
		mkpath($tmp_dir);
	}
	if (! defined $tmp_dir || ! -d $tmp_dir) {
		$tmp_dir = tempdir(CLEANUP => 1);
	}
	$self->{'_tmp_dir'} = $tmp_dir;

	# Verbose level.
	my $v = '-v'.$self->{'_opts'}->{'v'};

	# Copy DWG files to dir.
	my $dwg_file1_out = catfile($tmp_dir, 'first.dwg');
	copy($self->{'_dwg_file1'}, $dwg_file1_out);
	my $dwg_file2_out = catfile($tmp_dir, 'second.dwg');
	copy($self->{'_dwg_file2'}, $dwg_file2_out);

	# dwgread.
	my $dwgread1 = "$DR $v $dwg_file1_out";
	$self->_exec($dwgread1, 'first-dwgread', $self->{'_dwg_file1'});
	my $dwgread2 = "$DR $v $dwg_file2_out";
	$self->_exec($dwgread2, 'second-dwgread', $self->{'_dwg_file2'});

	# Diff.
	# TODO

	return 0;
}

sub _exec {
	my ($self, $command, $log_prefix, $dwg_file) = @_;

	my ($stdout, $stderr, $exit_code) = capture {
		system($command);
	};

	if ($exit_code) {
		print STDERR "Cannot dwgread '$dwg_file'.\n";
		print STDERR "\tCommand '$command' exit with $exit_code.\n";
		return;
	}

	if ($stdout) {
		my $stdout_file = catfile($self->{'_tmp_dir'},
			$log_prefix.'-stdout.log');
		barf($stdout_file, $stdout);
	}
	if ($stderr) {
		my $stderr_file = catfile($self->{'_tmp_dir'},
			$log_prefix.'-stderr.log');
		barf($stderr_file, $stderr);

		if (my @num = ($stderr =~ m/ERROR/gms)) {
			print STDERR "dwgread '$dwg_file' has ".scalar @num." ERRORs\n";
		}
	}

	return;
}

1;


__END__

=pod

=encoding utf8

=head1 NAME

App::Test::DWG::LibreDWG::DwgRead::Diff - Base class for test-dwg-libredwg-dwgread-diff script.

=head1 SYNOPSIS

 use App::Test::DWG::LibreDWG::DwgRead::Diff;

 my $app = App::Test::DWG::LibreDWG::DwgRead::Diff->new;
 my $exit_code = $app->run;

=head1 METHODS

=head2 C<new>

 my $app = App::Test::DWG::LibreDWG::DwgRead::Diff->new;

Constructor.

Returns instance of object.

=head2 C<run>

 my $exit_code = $app->run;

Run.

Returns 1 for error, 0 for success.

=head1 EXAMPLE

=for comment filename=test_dwg_files.pl

 use strict;
 use warnings;

 use App::Test::DWG::LibreDWG::DwgRead::Diff;

 # Arguments.
 @ARGV = (
         '__DWG_FILE1__',
         '__DWG_FILE2__',
 );

 # Run.
 exit App::Test::DWG::LibreDWG::DwgRead::Diff->new->run;

 # Output like:
 # TODO

=head1 DEPENDENCIES

L<Capture::Tiny>,
L<File::Copy>,
L<File::Path>,
L<File::Spec::Functions>,
L<File::Temp>,
L<Getopt::Std>,
L<IO::Barf>,
L<Readonly>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/App-Test-DWG-LibreDWG-DwgRead-Diff>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2023 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
