package Test::PlugAuth;

use strict;
use warnings;
use v5.10;

# ABSTRACT: minimum PlugAuth server to test Clustericious apps against
our $VERSION = '0.04'; # VERSION


1;

__END__

=pod

=head1 NAME

Test::PlugAuth - minimum PlugAuth server to test Clustericious apps against

=head1 VERSION

version 0.04

=head1 SYNOPSIS

assuming you have a Clustericious app MyApp with authentication/authorization
directives that you need to test:

 use File::HomeDir::Test;
 use File::HomeDir;
 use MyApp;
 use Mojo::UserAgent;
 use PlugAuth::Lite;
 
 my $auth_ua = Mojo::UserAgent->new;
 $auth_ua->app(
   PlugAuth::Lite->new({
     # see Mojolicious::Plugin::PlugAuthLite for details
     auth  => sub {
       my($user,$pass) = @_;
       return 1 if $user eq 'gooduser' && $pass eq 'goodpass';
       return;
     }
     authz => sub { 1 }, # return true for authorized
   })
 );
 
 # thanks to File::HomeDir::Test, ~/etc is actually /tmp/something/etc
 # and will be removed after the test is complete
 my $home = File::HomeDir->my_home;
 my $auth_url = "http://localhost:" . $auth_ua->app_url->port;
 mkdir "$home/etc";
 DumpFile("$home/etc/SomeService.conf", {
   plug_auth => {
     url => $auth_url,
   },
 });
 
 my $t = Test::Mojo->new("MyApp");
 
 $t->get_ok('/private')
   ->status_is(401);
 
 my $port = $t->ua->app_url->port;
 
 $t->get_ok("http://baduser:badpass\@localhost:$port/private")
   ->status_is(401);
 $t->geT_ok("http://gooduser:goodpass\@localhost:$port/private")
   ->status_is(200);

=head1 DESCRIPTION

This is a documentation only module.  In the future I will replace this
module with one that reduces some of the boiler plate above.

=head1 AUTHOR

Graham Ollis <plicease@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
