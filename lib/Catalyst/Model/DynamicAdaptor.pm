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
