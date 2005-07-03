package DBIx::Admin::CreateTrivialSchema;

# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114
#
# Note:
#	o Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 2003 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;

use Carp;

require 5.005_62;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DBIx::Admin::CreateTrivialSchema ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '1.01';

# -----------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(
		_dbh		=> 0,
		_default	=> undef,
		_not_null	=> 0,
		_schema		=> {},
		_type		=> 'varchar(255)',
		_verbose	=> 0,
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _standard_keys
	{
		keys %_attr_data;
	}

}	# End of encapsulated class data.

# -----------------------------------------------

sub new
{
	my($class, %arg)	= @_;
	my($self)			= bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	my($option) = $$self{'_not_null'} ? ' not null' : '';
	$option		.= defined($$self{'_default'}) ? $$self{'_default'} =~ /^\d+$/ ? " default $$self{'_default'}" : qq| default "$$self{'_default'}"| : '';

	my($table_name, $column_name, $sql);

	for $table_name (sort keys %{$$self{'_schema'} })
	{
		my(@column);

		for $column_name (@{$$self{'_schema'}{$table_name} })
		{
			push @column, qq|$column_name $$self{'_type'}$option|;
		}

		$sql = "create table $table_name (" . join(', ', @column) . ')';

		if ($$self{'_verbose'})
		{
			print STDERR "$sql. \n";
			print STDERR "\n";
		}

		eval{$$self{'_dbh'} -> do("drop table $table_name")};
		$$self{'_dbh'} -> do($sql);
	}

	return $self;

}	# End of new.

# -----------------------------------------------

1;

__END__

=head1 NAME

C<DBIx::Admin::CreateTrivialSchema> - Create a set of SQL create statements, and execute them

=head1 Synopsis

	use DBIx::Admin::CreateTrivialSchema;

	DBIx::Admin::CreateTrivialSchema -> new
	(
	    dbh      => $dbh,
	    not_null => 1,
	    schema   => {t_a => [col_a, col_b], t_z => [col_z]},
	    type     => 'char(2)',
	    verbose  => 1,
	);

=head1 Description

C<DBIx::Admin::CreateTrivialSchema> is a pure Perl module.

Given a hashref of tables and columns per table, it creates SQL create statements, and executes them.

The above schema would create and execute these SQL statements:

=over 4

=item create table t_a (col_a char(2) not null, col_b char(2) not null)

=item create table t_z (col_z char(2) not null)

=back

Any pre-existing tables with the same names are dropped first. Ensure your backups are up-to-date!

It should be obvious that this module is mindless in that all columns in all tables are given the same type,
the same 'not null' option, and the same default value.

This module is designed to use the output of C<DBIx::Admin::BackupRestore> V 1.07's sub get_column_names(),
which you can call after running that module's sub C<backup>.

So, the combined effect of these 2 modules is that you backup a database to XML with
C<DBIx::Admin::BackupRestore>, and then use C<DBIx::Admin::CreateTrivialSchema> to create a trivial schema
into which you jam the backed-up data with C<DBIx::Admin::BackupRestore>'s sub restore.

This enables you to get the data into some sort of schema when the create statements used to create
the original schema are not available on the target platform. For instance, use this technique when you
want to dump data from MS Access into Postgres under GNU/Linux.

This module is recommended instead of my previous attempt: C<DBIx::MSAccess::Convert2Db>.

See also: http://savage.net.au/Ron/html/msaccess2rdbms.html

For a more sophisticated migration technique, see:

http://dev.mysql.com/tech-resources/articles/migrating-from-microsoft.html

=head1 Distributions

This module is available both as a Unix-style distro (*.tgz) and an
ActiveState-style distro (*.ppd). The latter is shipped in a *.zip file.

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing each type of distro.

=head1 Constructor and initialization

new(...) returns an object of type C<DBIx::Admin::CreateTrivialSchema>.

This is the class's contructor.

Usage: DBIx::Admin::CreateTrivialSchema -> new().

This method takes a set of parameters.

For each parameter you wish to use, call new as new(param_1 => value_1, ...).

=over 4

=item dbh

This is a database handle.

The generated SQL will be executed against this handle.

This parameter is mandatory.

=item default

This parameter takes a value to be inserted into the create statement, which
specifies the default value you want for all columns.

A value of 99, which matches /^\d+$/, means generate this code:

create table t (column_a varchar(255) default 99).

Notice how the value you supply is inserted without quotes, because it matched /^\d+$/.

A value of '-' means generate this code:

create table t (column_a varchar(255) default "-").

Notice how the value you supply, if not all digits, is put inside double quotes.

Do not provide a value of ", because it simply won't work.

The default value is undef, which means the default clause is not inserted into the SQL.

This parameter is optional.

=item not_null

This paramater takes the values 0 and 1, where 0 means do not insert a 'not null' clause into the SQL,
and 1 means insert ' not null' into the generated SQL.

The default value is 0.

This parameter is optional.

=item schema

This is a hash ref whose keys are the table names, and whose values are array refs of column names.

See the Synopsis for an example.

The default value is {}.

This parameter is mandatory.

=item type

This parameter takes a string to be inserted into the create statement, which
specifies the data type of all columns.

The default value is 'varchar(255)'.

This parameter is optional.

=item verbose

This paramater takes the values 0 and 1, where 0 means do not print anything to STDERR,
and 1 means print the generated SQL.

The default value is 0.

This parameter is optional.

=back

=head1 Required Modules

=over 4

=item Carp

=back

=head1 Changes

See Changes.txt.

=head1 Author

C<DBIx::Admin::CreateTrivialSchema> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>>
in 2005.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2005, Ron Savage. All rights reserved.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
