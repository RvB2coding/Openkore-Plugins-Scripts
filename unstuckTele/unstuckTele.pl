#--------------------------------------------------------------------
#    unstuckTele       by alisonrag
#--------------------------------------------------------------------
#
#    Unstuck Teleport
#
#--------------------------------------------------------------------
#    Licensed under the GNU General Public License v2.0
#--------------------------------------------------------------------

# config.txt:
# unstuckTele_inCity <boolean> - disable | enable check in Cities
# unstuckTele_inLockOnly <boolean> - disable | enable check in Cities
# unstuckTele_allowedMaps <Map Names> - list of maps allowed to check 
# unstuckTele_useItem <boolean> - disable | enable the item Use 
# unstuckTele_useItemID <number> - itemID
# unstuckTele_useSkill <boolean> - disable | enable the use of Teleport Skill
# unstuckTele_idleTime <number> - Time in seconds to check. start after map-login then will repeat after every x seconds
# unstuckTele_notOnAI <AI action List> - List of Actions in AI, when set the plugin will ignore the check if a action is in queue

# notes: 
# if 'inCity' and 'inLockOnly' are disabled and 'allowedMaps' is empty Kore will check for timeout in every map
# 'inLockOnly' have priority over 'allowedMaps'
# 'useSkill' have priority over the 'useItem'

package unstuckTele;

# default imports
use strict;
use Network;
use Network::PacketParser;
use Globals qw($net %config $field %timeout $char $accountID);
use Log qw(message warning debug error);
use Utils qw(timeOut existsInList);

#--------------------------------------------------------------
# Setting startup information
#--------------------------------------------------------------
use constant {
    PLUGIN_PREFIX => "[UNSTUCK_TELE]",
    PLUGIN_NAME => "unstuckTele",
	TIMEOUT_CHECK => "unstuck_check",
    TIMEOUT_VALUE_REQUEST => 30,    
     
};

Plugins::register(PLUGIN_NAME,'unstuck Character by using Teleport', \&onUnload);

my $hooks = Plugins::addHooks(
	[ 'initialized',							\&onInitialized], # Start Timeout Values
	[ 'packet/received_character_ID_and_Map',	\&onReceivedCharacterIDAndMap ], # Start/Reset Timer after Login
	[ 'packet/map_change',						\&onMapChange ], # Reset Timer After Teleport (same map-server)
	[ 'packet/map_changed',						\&onMapChanged ], # Reset Timer After Change Map (different map-server)
	[ 'packet/inventory_item_added',			\&onInventoryItemAdded ], # Reset Timer After add item to inventory
	[ 'packet/actor_action', 					\&onActorAction ], # Reset Timer After Attack / Pickup
	[ 'packet/skill_use',						\&onSkillUse ], # Reset After Use Skill	
    [ 'AI_post',            					\&onAIPost ], # Check if we are stuck
);

my @notAI;

#--------------------------------------------------------------
# Core subroutines
#--------------------------------------------------------------

# What to do when the plugin is unloaded/reloaded:
sub onUnload {
    Plugins::delHooks($hooks);    
	undef @notAI;
}

sub onInitialized {
	$timeout{&TIMEOUT_CHECK}{timeout} = $config{PLUGIN_NAME . '_idleTime'} || TIMEOUT_VALUE_REQUEST;
	$timeout{&TIMEOUT_CHECK}{time} = time;
	@notAI = split /,/, $config{PLUGIN_NAME . '_notOnAI'};
}

sub onReceivedCharacterIDAndMap {
	$timeout{&TIMEOUT_CHECK}{time} = time;
	debug PLUGIN_PREFIX . " Reseting time due to received_character_ID_and_Map. \n";
}

sub onMapChange {
	$timeout{&TIMEOUT_CHECK}{time} = time;
	debug PLUGIN_PREFIX . " Reseting time due to map_change. \n";
}

sub onMapChanged {
	$timeout{&TIMEOUT_CHECK}{time} = time;
	debug PLUGIN_PREFIX . " Reseting time due to map_changed. \n";
}

sub onInventoryItemAdded {
	my ($self, $args) = @_;
	
	if (!$args->{fail}) { # if not fail
		$timeout{&TIMEOUT_CHECK}{time} = time;
		debug PLUGIN_PREFIX . " Reseting time due to inventory_item_added. \n";
	}
}

sub onActorAction {
	my ($self, $args) = @_;
	
	if($args->{'sourceID'} eq $accountID) { # check if actor is our char
		return if($args->{type} == ACTION_SIT || $args->{type} == ACTION_STAND); # return if we are siting or standing up
		$timeout{&TIMEOUT_CHECK}{time} = time;
		debug PLUGIN_PREFIX . " Reseting time due to actor_action. \n";
	}
}

sub onSkillUse {
	my ($self, $args) = @_;
	
	if($args->{'sourceID'} eq $accountID) { # check if actor is our char
		$timeout{&TIMEOUT_CHECK}{time} = time;
		debug PLUGIN_PREFIX . " Reseting time due to skill_use. \n";
	}
}

sub onAIPost {
	return if($net->getState() != Network::IN_GAME); # return if we are not in game	
	return if(!timeOut($timeout{&TIMEOUT_CHECK}));	# return if not timeOut
	return if AI::inQueue(@notAI); # return if the defined actions are in AI queue
	return if((!$config{PLUGIN_NAME . '_inCity'}) && ($field->isCity())); # return if we are in city and inCity == 0
	
	debug PLUGIN_PREFIX . " I need to use teleport. \n";	
	$timeout{&TIMEOUT_CHECK}{time} = time;
		
	if($config{PLUGIN_NAME . '_inLockOnly'}) { # check if in inLockOnly is enabled and if we are in lockMap
		if($field->{baseName} eq $config{'lockMap'}) { 
			&useTele();
		}
	} elsif($config{PLUGIN_NAME . '_allowedMaps'}) { # check if in allowedMaps is set and if the current map is in list
		if(existsInList($config{PLUGIN_NAME . '_allowedMaps'}, $field->{baseName})) {
			&useTele();
		}
	} else { # inLockOnly and allowedMaps are not set, but the timeOut is ok
		&useTele();
	}
}

sub useTele {
	if($config{PLUGIN_NAME . '_useSkill'}) { # teleport using skill
		main::useTeleport(1);
	} elsif($config{PLUGIN_NAME . '_useItem'} && $config{PLUGIN_NAME . '_useItemID'}) { # teleport using item
		my $item = $char->inventory->getByNameID( $config{PLUGIN_NAME . '_useItemID'} );
		if($item) {
			$item->use;
		} else {
			warning PLUGIN_PREFIX . " We dont have the item (".$config{PLUGIN_NAME . '_useItemID'}.") \n";
		}
	} else {
		warning PLUGIN_PREFIX . " Skill and Item to Teleport are not set \n";
	}
}

1;