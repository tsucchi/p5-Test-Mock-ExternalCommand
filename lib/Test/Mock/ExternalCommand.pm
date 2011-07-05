package Test::Mock::ExternalCommand;
use strict;
use warnings;
use Config;
use File::Spec;
use File::Temp qw(tempdir mkstemp);

use 5.008;
our $VERSION = '0.01';

=head1 NAME

Test::Mock::ExternalCommand - Create mock external-command easily

=head1 SYNOPSIS

  use Test::Mock::ExternalCommand;
  my $m = Test::Mock::ExternalCommand->new();
  $m->set_command( 'my-command-aaa', 'command-output', 0);
  # use 'my-command-aaa' in your test.

=head1 DESCRIPTION

Test::Mock::ExternalCommand enable to make mock-external command in easy way.

=head1 Methods

=cut

=head2 new( script_dir => "/script/dir/used/in/this/module" )

parameter <I>script_dir</I> is directory where mock will be installed. If <I>script_dir</I>is omitted, temporary directory is automatically generated and deleted when object is not used.

=cut

sub new {
    my $class = shift;
    my %options = @_;

    my $script_dir = $options{script_dir} || _default_script_dir();
    my $self = {
        script_dir           => $script_dir,
        command_history_file => File::Spec->catfile( (mkstemp( "historyXXXX" ))[1] ),
    };
    bless $self, $class;
}

=head2 set_command( $command_name,  $command_output_string, $command_exit_status )

set mock external command command. Mock external scripts are deleted when object is DESTROY'ed.

=cut

sub set_command {
    my $self = shift;
    my( $command_name, $command_output, $command_exit_status) = @_;
    mkdir $self->script_dir if ( !-d $self->script_dir );

    my $command_file = File::Spec->catfile($self->script_dir, $command_name);
    push @{ $self->{command_files} },$command_file;

    open( my $command_fh, '>', $command_file ) || die $!;
    print {$command_fh} $self->_command_script_body( $command_file,
                                                     $command_output,
                                                     $command_exit_status);
    close($command_fh);
    chmod 0755, $command_file;

    $ENV{PATH} = sprintf("%s%s%s", $self->script_dir, $Config{path_sep}, $ENV{PATH});
}

=head2 history

return command history.

=cut

sub history {
    my $self = shift;
    my @result;
    open(my $history_fh, '<', $self->{command_history_file}) || die $!;
    while( my $line = <$history_fh> ) {
        my @command_and_args = split(/\s+/, $line);
        push @result, \@command_and_args;
    }
    close($history_fh);
    return @result;
}


=head2 script_dir

return script_dir set in new() or automatically set.

=cut

sub script_dir {
    return shift->{script_dir};
}


sub _command_script_body {
    my $self = shift;
    my($command_filename, $output, $exit_status) = @_;
    $exit_status = 0 if ( !defined $exit_status );
    my $history_file = $self->{command_history_file};
    my $script_dir = $self->script_dir;
    $command_filename =~ s{^$script_dir/?}{};

    my $mode = -e $history_file ? '>>' : '>';
    return <<EOS;
#!/usr/bin/perl -w
use strict;
use warnings;

open(my \$HISTORY, '$mode', "$history_file") || die \$!;
print {\$HISTORY} "$command_filename \@ARGV\\n";
close(\$HISTORY);

print "$output";

exit $exit_status;
EOS
}

sub _default_script_dir {
    (my $pkg = lc(__PACKAGE__) . "XXXX") =~ s/::/-/g;
    return tempdir( $pkg, DIR => File::Spec->tmpdir(), CLEANUP => 1 );
}

sub DESTROY {
    my $self = shift;
    unlink $self->{command_history_file};
    for my $command_file ( @{ $self->{command_files} } ) {
        unlink $command_file;
    }
    rmdir $self->{script_dir} || warn $!;
}


1;
__END__

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=head1 SEE ALSO

=head1 Copyright

Copyright (c) 2010-2011 Takuya Tsuchida

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
