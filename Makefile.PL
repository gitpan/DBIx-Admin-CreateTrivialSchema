use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'Create a set of SQL create statements, and execute them',
    ) : (),
	clean			=>
	{
		FILES		=> 'blib/* Makefile MANIFEST DBIx-Admin-CreateTrivialSchema-*'
	},
	dist			=>
	{
		COMPRESS	=> 'gzip',
		SUFFIX		=> 'gz'
	},
	DISTNAME		=> 'DBIx-Admin-CreateTrivialSchema',
	NAME			=> 'DBIx::Admin::CreateTrivialSchema',
	PL_FILES		=> {},
	PREREQ_PM		=>
	{
		Carp			=> 0,
	},
	VERSION_FROM	=> 'lib/DBIx/Admin/CreateTrivialSchema.pm',
);
