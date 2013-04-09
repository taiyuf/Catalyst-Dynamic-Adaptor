Catalyst-Model-DynamicAdaptor
===============
This is Dynamically load adaptor modules by perl.

# How to use

## Create your module as Model.

    package MyApp::Web::Model::Logic;
    
    use base qw/Catalyst::Model::DynamicAdaptor/;
    
    __PACKAGE__->config(
        class => 'MyApp::Logic',         # all modules under MyApp::Logic::* will be loaded
        root  => '/path/to/MyApp/Logic', # MyApp::Logic diretcory
    );
    
    1;

You can call MyApp::Logic::* as MyApp::Model::Logic::*. 

## Write your business logic on logic module and define ACCEPT_CONTEXT method.

    package MyApp::Logic;
    
    use Moose;
    use namespace::autoclean;
    
    sub ACCEPT_CONTEXT {
        my ($self, $c, @array) = @_;
    
        # use catalyst object: $c as you like.
    
    return $self.
    }
    
    sub BUILD {
    
    ....
    
    }
    
    1;

and create some child class.
    
    package MyApp::Logic::Foo;
    
    use Moose;
    use namespace::autoclean;

    extends qw/MyApp::Logic/;
    
    sub bar {
        my $self = shift;
    
    ....
    
    }
    
    1;

## You can call your method by $c->model() method in web application writen by catalyst.

    package MyApp::Web::Controller::Foo;
    
    sub foo : Local {
        my ( $self, $c ) = @_;
    
        $c->model('Logic::Foo')->bar() ; 
    }
    
    1;

## You can call your method like other module, too.

    package MyApp::CLI;
    
    use MyApp::Logic::Foo;
    
    sub hoge {
        my $self = shift;
    
        my $logic = MyApp::Logic::Foo->new();
        $logic->bar();
    }
    
    1;

# Licence

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

