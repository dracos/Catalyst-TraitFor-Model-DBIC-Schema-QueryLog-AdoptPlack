package Catalyst::TraitFor::Model::DBIC::Schema::QueryLog::AdoptPlack;
our $VERSION = "0.03";

use 5.008;
use namespace::autoclean;
use Moose::Role;
use Carp::Clan '^Catalyst::Model::DBIC::Schema';
with 'Catalyst::Component::InstancePerContext';
requires 'storage';

sub get_querylog_from_env {
  my ($self, $env) = @_;
  return $env->{'plack.middleware.debug.dbic.querylog'} ||
    $env->{'plack.middleware.dbic.querylog'};
}

sub build_per_context_instance {
  my ( $self, $ctx ) = @_;
  if(defined $ctx->engine->env) {
    my $querylog = $self->get_querylog_from_env($ctx->engine->env) ||
      die "Cannot find a querylog instance in the plack env";

    $self->storage->debugobj($querylog);
    $self->storage->debug(1);
    return $self;
  } else {
      die "Not a Plack Engine or compatible interface!";
  }
}

1;

=head1 NAME

Catalyst::TraitFor::Model::DBIC::Schema::QueryLog::AdoptPlack - Use a Plack Middleware QueryLog

=head2 SYNOPSIS

    package MyApp::Web::Model::Schema;
    use parent 'Catalyst::Model::DBIC::Schema';

	__PACKAGE__->config({
        schema_class => 'MyApp::Schema',
        traits => ['QueryLog::AdoptPlack'],
        ## .. rest of configuration
	});

=head1 DESCRIPTION

This is a trait for L<Catalyst::Model::DBIC::Schema> which adopts a L<Plack>
created L<DBIx::Class::QueryLog> and logs SQL for a given request cycle.  It is
intended to be compatible with L<Catalyst::TraitFor::Model::DBIC::Schema::QueryLog>
which you may already be using.

It picks up the querylog from C<< $env->{'plack.middleware.dbic.querylog'} >>
or from  C<< $env->{'plack.middleware.debug.dbic.querylog'} >>  which is generally
provided by the L<Plack> middleware L<Plack::Middleware::Debug::DBIC::QueryLog>
In fact you will probably use these two modules together.  Please see the documentation
in L<Plack::Middleware::Debug::DBIC::QueryLog> for an example.

PLEASE NOTE: Starting with the 0.04 version of L<Plack::Middleware::Debug::DBIC::QueryLog>
we will canonicalize on C<< $env->{'plack.middleware.dbic.querylog'} >>.  For now
both aobve keys will work, but within a release or two the older key will warn and
prompt you to upgrade your version of L<Plack::Middleware::Debug::DBIC::QueryLog>.
Sorry for the trouble.

=head1 SEE ALSO

L<Plack::Middleware::Debug::DBIC::QueryLog>,
L<Catalyst::TraitFor::Model::DBIC::Schema::QueryLog>, L<Catalyst::Model::DBIC::Schema>,
L<Plack::Middleware::Debug>

=head1 ACKNOWLEGEMENTS

This code inspired from L<Catalyst::TraitFor::Model::DBIC::Schema::QueryLog>
and the author owes a debt of gratitude for the original authors.

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010, John Napiorkowski

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
