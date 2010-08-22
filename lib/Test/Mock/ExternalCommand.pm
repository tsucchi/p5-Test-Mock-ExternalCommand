package Test::Mock::ExternalCommand;
use strict;
use warnings;
use Config;
use File::Spec::Functions qw(catfile);

use '5.008';
our $VERSION = '0.01';

=head1 NAME

Test::Mock::ExternalCommand - Create mock external-command easily

=head1 SYNOPSIS

  use Test::Mock::ExternalCommand;

=head1 DESCRIPTION

Test::Mock::ExternalCommand is

=head1 Methods

=cut

=head2 new( script_dir => "/script/dir/used/in/this/module" )

parameter <I>script_dir</I> is directory where mock will be installed.

=cut

sub new {
    my $class = shift;
    my %options = @_;

    my $self = {
        script_dir => $options{script_dir},
    };
    bless $self, $class;
}

=head2 set_command( $command_name,  $command_output_string, $command_exit_status )

set mock external command command. Mock external scripts are deleted when object is DESTROY'ed.

=cut

sub set_command {
    my $self = shift;
    my( $command_name, $command_output, $command_exit_status) = @_;
    mkdir $self->{script_dir};

    my $command_file = catfile($self->{script_dir}, $command_name);
    push @{ $self->{command_files} },$command_file;

    open( my $command_fh, '>', $command_file ) || die $!;
    print {$command_fh} _command_script_body($command_output, $command_exit_status);
    close($command_fh);
    chmod 0755, $command_file;

    $ENV{PATH} = sprintf("%s%s%s", $self->{script_dir}, $Config{path_sep}, $ENV{PATH});
}

sub _command_script_body {
    my($output, $exit_status) = @_;

    return <<EOS;
#!/usr/bin/perl -w
use strict;
use warnings;

print "$output";
exit $exit_status;
EOS
}


sub DESTROY {
    my $self = shift;
    for my $command_file ( @{ $self->{command_files} } ) {
        unlink $command_file;
    }
    rmdir $self->{script_dir};
}


1;
__END__

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=head1 SEE ALSO

=head1 Copyright

Copyright (c) 2010 Takuya Tsuchida

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
