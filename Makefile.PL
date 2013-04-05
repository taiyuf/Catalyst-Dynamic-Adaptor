use inc::Module::Install;

name 'Catalyst-Model-DynamicAdaptor';
all_from 'lib/Catalyst/Model/DynamicAdaptor.pm';

requires 'mro';
requires 'Module::Recursive::Require';

WriteAll;
