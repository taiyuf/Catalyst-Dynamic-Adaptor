package Catalyst::Model::DynamicAdaptor;

use Moose;
use namespace::autoclean;
use mro 'c3';
use Module::Recursive::Require;

BEGIN { extends 'Catalyst::Model' };

our $VERSION = 0.1;

has class => (is => 'rw');

has root  => (is => 'rw');

sub BUILD {

    my ($class, $app, @rest) =@_;
    my $arg = {};

    if (scalar @rest) {
        if (ref($rest[0]) eq 'HASH') {
            $arg = $rest[0];
        } else {
            $arg = { @rest };
        }
    }

    my $self       = $class->next::method($app, $arg);
    my $class_ref  = ref($self);
    my $base_class = $self->class;
    my $root       = $self->root || $INC[0];
    my $args       = {path => $self->root};
    my @plugins    = Module::Recursive::Require->new($args)->require_of($base_class);

    no strict 'refs';
    for my $plugin (@plugins) {

        my $plugin_short = $plugin;
        $plugin_short    =~ s/^$base_class\:\://g;
        my $classname    = "${class_ref}::$plugin_short";
        my $obj;

        eval {
            $obj = $plugin->new($arg);
        };
        if ($@) {
            *{"${classname}::ACCEPT_CONTEXT"} = sub {
                warn __PACKAGE__ . ": " . $@;
                shift;
                return eval $plugin . "::ACCEPT_CONTEXT(shift)";
            };
        } else {
            *{"${classname}::ACCEPT_CONTEXT"} = sub {
                shift;
                return $obj->ACCEPT_CONTEXT(shift);
            };
        }
    }

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Catalyst::Model::DynamicAdaptor - Dynamically load adaptor modules

=head1 VERSION

0.1

=head1 SYNOPSIS

 package MyApp::Web::Model::Logic;

 use base qw/Catalyst::Model::DynamicAdaptor/;

 __PACKAGE__->config(
      class => 'MyApp::Logic',         # all modules under MyApp::Logic::* will be loaded
      root  => '/path/to/MyApp/Logic', # MyApp::Logic diretcory
   );

 1;

 package MyApp::Logic;

 use Moose;
 use namespace::autoclean;

 sub ACCEPT_CONTEXT {
     my ($self, $c, @array) = @_;

     # use catalyst object: $c as you like.

     return $self;
 }

 sub BUILD {

 .....
'
 }

 1;

 package MyApp::Logic::Foo;

 use Moose;
 use namespace::autoclean;

 extends qw/MyApp::Logic/;

 sub bar {
     my $self = shift;

     ....
 }

 1;

 package MyApp::Web::Controller::Foo;

 sub foo : Local {
     my ( $self, $c ) = @_;

     $c->model('Logic::Foo')->bar() ;
 }

 1;

 # For not web application modules.

 package MyApp::CLI;

 use MyApp::Logic::Foo;

 sub hoge {
     my $self = shift;

     my $logic = MyApp::Logic::Foo->new();
     $logic->bar();
 }

 1;

=head1 DESCRIPTION

 Load modules dynamicaly like L<Catalyst::Model::DBIC::Schema> does.

=head1 MODULE

=head2 new

constructor

=head1 AUTHOR

Taiyu Fujii <tf.900913@gmail.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
