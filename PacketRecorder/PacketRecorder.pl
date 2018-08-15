# This plugin records packets into a file.
#
# Configuration options:
# recordPacket (FILENAME)
#    Packets will be recorded to FILENAME.

package PacketRecorder;

use strict;
use Plugins;
use Globals;
use Log qw(message error);
use Utils;


Plugins::register("Packet Recorder", "Packet Recorder", \&on_unload);
my $hooks = Plugins::addHooks(
	['parseMsg/pre', \&on_parseMsg],
	['sendMessage/pre', \&on_sendMsg],
);

open(F, ">>:utf8", "$Settings::logs_folder/packets.txt");

sub on_unload {
	Plugins::delHooks($hooks);
	close(F);
}

sub on_parseMsg {
	my (undef, $args) = @_;
	my $packet_id = uc(unpack("H2", substr($args->{msg}, 1, 1))) . uc(unpack("H2", substr($args->{msg}, 0, 1)));
	my $handler = $packetParser->{packet_list}{$packet_id}[0] || "unknown";
	print F "----------\n";
	print F "Direction Server to Client << \n";
	print F "Captured Hex: ".getHex($args->{msg})."\n";
	print F "Infos:\n";
	print F "Packet ID: 0x".$packet_id."\n";
	print F "Handler: ".$handler."\n";
	print F "Length: ".length($args->{msg})." bytes\n";
	print F "TimeStamp: ".getFormattedDateShort(int(time),2)."\n";
	print F "----------\n";
}

sub on_sendMsg {
	my (undef, $args) = @_;
	my $packet_id = uc(unpack("H2", substr($args->{msg}, 1, 1))) . uc(unpack("H2", substr($args->{msg}, 0, 1)));
	my $handler = $messageSender->{packet_list}{$packet_id}[0] || "unknown";
	print F "----------\n";
	print F "Direction Client to Server >> \n";
	print F "Captured Hex: ".getHex($args->{msg})."\n";
	print F "Infos:\n";
	print F "Packet ID: 0x".$packet_id."\n";
	print F "Handler: ".$handler."\n";
	print F "Length: ".length($args->{msg})." bytes\n";
	print F "TimeStamp: ".getFormattedDateShort(int(time), 2)."\n";
	print F "Current CryptKey: 0x".hex($messageSender->{encryption}->{crypt_key})."\n";
	print F "----------\n";
}

1;
