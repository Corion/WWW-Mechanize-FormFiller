#!/usr/bin/perl -w

use Test::More 'no_plan';

package Catch;

sub TIEHANDLE {
    my($class, $var) = @_;
    return bless { var => $var }, $class;
}

sub PRINT  {
    my($self) = shift;
    ${'main::'.$self->{var}} .= join '', @_;
}

sub OPEN  {}    # XXX Hackery in case the user redirects
sub CLOSE {}    # XXX STDERR/STDOUT.  This is not the behavior we want.

sub READ {}
sub READLINE {}
sub GETC {}

my $Original_File = 'lib/WWW/Mechanize/FormFiller/Value/Fixed.pm';

package main;

# pre-5.8.0's warns aren't caught by a tied STDERR.
$SIG{__WARN__} = sub { $main::_STDERR_ .= join '', @_; };
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

    undef $main::_STDOUT_;
    undef $main::_STDERR_;
eval q{
  my $example = sub {
    local $^W = 0;

#line 27 lib/WWW/Mechanize/FormFiller/Value/Fixed.pm

  use WWW::Mechanize::FormFiller;
  use WWW::Mechanize::FormFiller::Value::Fixed;

  my $f = WWW::Mechanize::FormFiller->new();

  # Create a fixed value for the HTML field "login"
  my $fixed = WWW::Mechanize::FormFiller::Value::Fixed->new( login => "Corion" );
  $f->add_value( login => $fixed );

  # Alternatively take the following shorthand, which adds the
  # field to the list as well :
  my $password = $f->add_filler( password => Fixed => "secret" );

;

  }
};
is($@, '', "example from line 27");

    undef $main::_STDOUT_;
    undef $main::_STDERR_;

