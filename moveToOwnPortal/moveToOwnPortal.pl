package moveToOwnPortal;

# default imports
use strict;
use Globals qw($accountID);
use Log qw(message warning debug error);

#--------------------------------------------------------------
# Setting startup information
#--------------------------------------------------------------
use constant {
    PLUGIN_PREFIX => "[OWNPORTAL]",
    PLUGIN_NAME => "moveToOwnPortal",
};

Plugins::register(PLUGIN_NAME,'unstuck Character by using Teleport', \&onUnload);

my $hooks = Plugins::addHooks(
	[ 'packet/skill_use_location',	\&onSkillUseLocation], # Move to your own portal
);

sub onUnload {
    Plugins::delHooks($hooks);    
}

sub onSkillUseLocation {
	my ($self, $args) = @_;
	
	if($args->{sourceID}eq $accountID && $args->{skillID} == 27) {
		warning PLUGIN_PREFIX." Own portal detected moving to inside. (".$args->{x}.",".$args->{y}.")\n";
		Commands::run("ai manual");
		Commands::run("ai clear");
		Commands::run("move $args->{x} $args->{y}");
		Commands::run("ai auto");
	}
}