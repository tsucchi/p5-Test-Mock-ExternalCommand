package Test::Mock::ExternalCommand;
use strict;
use warnings;
use Config;

use 5.008;
our $VERSION = '0.01';

my $command_registry = {};
my $print_buf = "";
my $print_override = 0;

BEGIN {
    sub _command_and_args {
        my ( $command, @args ) = @_;
        my ( $command_real, @args2 ) = split qr/\s+/, $command;
        my @args_real = (@args2, @args);
        return ($command_real, @args_real);
    }

    *CORE::GLOBAL::system = sub {
        my ( $command, @args ) = _command_and_args(@_);
        if ( defined $command_registry->{$command} ) {
            return $command_registry->{$command}->{system}->(@args);
        }
        CORE::system(@_);
    };
    *CORE::GLOBAL::readpipe = sub {
        my ( $command, @args ) = _command_and_args(@_);
        if ( defined $command_registry->{$command} ) {
            return $command_registry->{$command}->{readpipe}->(@args);
        }
        CORE::readpipe(@_);
    };
}


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

=head2 new()

=cut

sub new {
    my ( $class ) = @_;
    my $self = {
        command_history => [],
    };
    bless $self, $class;
}

=head2 set_command( $command_name,  $command_output_string, $command_exit_status )

set mock external command command.

=cut

sub set_command {
    my ( $self, $command_name, $command_output, $command_exit_status ) = @_;
    $command_registry->{$command_name}->{system} = sub {
        my ( @args ) = @_;
        push @{ $self->{command_history} }, [$command_name, @args];
        print $command_output;
        return $command_exit_status << 8;
    };

    $command_registry->{$command_name}->{readpipe} = sub {
        my ( @args ) = @_;
        push @{ $self->{command_history} }, [$command_name, @args];
        return $command_output;
    };
}

=head2 set_command_by_coderef( $command_name,  $command_behavior_subref )

set mock external command command using subroutine reference(coderef).

=cut

sub set_command_by_coderef {
    my ( $self, $command_name, $command_behavior_subref ) = @_;
    $command_registry->{$command_name}->{system} = sub {
        my ( @args ) = @_;
        push @{ $self->{command_history} }, [$command_name, @args];
        my $ret =  $command_behavior_subref->(@args);
        return $ret << 8;
    };
    $command_registry->{$command_name}->{readpipe} = sub {
        my ( @args ) = @_;
        push @{ $self->{command_history} }, [$command_name, @args];
        return $command_behavior_subref->(@args);
    };
}

=head2 history

return command history.

=cut

sub history {
    my ( $self ) = @_;
    return @{ $self->{command_history} };
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
