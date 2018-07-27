#unstuck plugin by:Naozumi2k
package unstuck;

use strict;
use Globals;
use Plugins;

Plugins::register('unstuck', 'force relog when stuck during route', \&on_unload, \&on_unload);

my $hook = Plugins::addHook("route", \&on_route);

sub on_unload {
    Plugins::delHook('route', $hook);
}

sub on_route {
    my (undef, $args) = @_;
    if($args->{status} eq "stuck"){
        Commands::run("reload portal");
        Commands::run("relog");
    }
}

1;