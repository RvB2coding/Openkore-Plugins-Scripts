# Test plugin to use simi simi api
# see more in:
# http://developer.simsimi.com/api

# by alisonrag

package autoResponse;

use strict;
use Plugins;
use Commands;
use Globals;
use Utils;
use Misc;
use Log qw(message error warning);
use LWP::UserAgent; 
use JSON;
 
Plugins::register("autoResponse", "respondi as mensagem", \&unload);

my %playerList;

my %pluginConfig = (
   prefix => "autoResponse",
   notInTown => 0,
   checkResponse => 1,
   failDefaultReaction => "relog 300",
   talkToMuchDefaultReaction => "relog 300",
   maxDistance => 20   
);

my $hooks  = Plugins::addHooks(
	['packet_privMsg', \&received_pm],
	['packet_pubMsg', \&received_m]  
);

sub received_pm {
	my (undef, $args) = @_;	
	my $player = $args->{privMsgUser};
	my $privMsg = $args->{privMsg};
	$privMsg =~ s/\"//g;	$privMsg =~ s/^\s+//g;	$privMsg =~ s/\s+$//g;	$privMsg =~ s/ç/c/g; $privMsg  =~ s/\s/\+/g; #clean msg	
	
	if ($pluginConfig{notInTown} > 0) { return 0 if ($field->isCity); }
	if (exists($playerList{$player})) {$playerList{$player}++;} else {$playerList{$player} = 1;}
	if ($playerList{$player} > 5) { Commands::run($pluginConfig{failDefaultReaction}); }
	my $response = getResponse($privMsg);
	
	if($response && $pluginConfig{checkResponse} > 0) {
	my $tasks = new Task::Chained(
			tasks => [
				new Task::Wait(seconds => 5),
				new Task::Function(function => sub {            
					my ($task) = @_;            
					sendMessage($messageSender, "pm", $response, $player);
					$task->setDone();
				}
				)
			]
		 );		
	} else {
		$response = getResponse($privMsg);
		if($response) {
		my $tasks = new Task::Chained(
			tasks => [
				new Task::Wait(seconds => 5),
				new Task::Function(function => sub {            
					my ($task) = @_;            
					sendMessage($messageSender, "pm", $response, $player);
					$task->setDone();
				}
				)
			]
		 );
			
		} else {
			message "[$pluginConfig{prefix}] Estou executando a ação preventiva padrão pois viadin do ed não me respondeu nada... \n";
			Commands::run($pluginConfig{failDefaultReaction});
		}
	}	
}

sub received_m {
	my (undef, $args) = @_;
	my $playerId = $args->{pubID};
	my $player = $args->{pubMsgUser};
	my $pubMsg = $args->{pubMsg};	
	$pubMsg =~ s/\"//g;	$pubMsg =~ s/^\s+//g;	$pubMsg =~ s/\s+$//g;	$pubMsg =~ s/ç/c/g;	$pubMsg =~ s/\s/\+/g; #clean msg
	
	if ($pluginConfig{notInTown} > 0) { return 0 if ($field->isCity); }	
	return 0 if(getPlayerDistance($playerId) > $pluginConfig{maxDistance});	
	if (exists($playerList{$player})) {$playerList{$player}++;} else {$playerList{$player} = 1;}
	if ($playerList{$player} > 5) { Commands::run($pluginConfig{failDefaultReaction}); }
	my $response = getResponse($pubMsg);	
	
	if($response && $pluginConfig{checkResponse} > 0) {
		my $tasks = new Task::Chained(
			tasks => [
				new Task::Wait(seconds => 5),
				new Task::Function(function => sub {            
					my ($task) = @_;            
					sendMessage($messageSender, "c", $response);
					$task->setDone();
				}
				)
			]
		 );		 
		  $taskManager->add($tasks);
		
	} else {
		$response = getResponse($pubMsg);
		if($response) {
			my $tasks = new Task::Chained(
			tasks => [
				new Task::Wait(seconds => 5),
				new Task::Function(function => sub {            
					my ($task) = @_;            
					sendMessage($messageSender, "c", $response);
					$task->setDone();
				}
				)
			]
		 );
		 
		  $taskManager->add($tasks);
		} else {
			message "[$pluginConfig{prefix}] Estou executando a ação preventiva padrão pois viadin do ed não me respondeu nada... \n";
			Commands::run($pluginConfig{failDefaultReaction});
		}
	}	
}

sub getResponse {
	my $msg = shift;
	my $ua = new LWP::UserAgent;
	$ua->agent('Mozilla/5.0');
	$ua->timeout(20);
	$ua->default_header('Accept-Encoding' => scalar HTTP::Message::decodable());
	
	my $response = $ua->get('http://sandbox.api.simsimi.com/request.p?key=67542c90-bfe4-4608-af54-6b1924d2d6f2&lc=pt&ft=1.0&text='.$msg);
	
	if ($response->is_success) {
		my $content = $response->decoded_content();		
		my $text = decode_json($content);
				
		if ($text->{'result'} eq '100') {
			return $text->{'response'};
		}
		else {
		return 0;
		}
	} else {
		return 0;
	}
}

sub getPlayerDistance {
	my $playerId = shift;
	my $actor = Actor::get($playerId);
	my $dist = distance($char->{pos_to}, $actor->{pos_to});
	return $dist;
}

sub unload {
   Plugins::delHooks($hooks);
   undef $hooks;
}

1;