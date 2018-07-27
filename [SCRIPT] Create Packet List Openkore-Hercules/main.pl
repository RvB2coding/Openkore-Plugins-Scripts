#!/usr/bin/env/perl
use strict;
use warnings;
use Packets;

open(my $input, '<:encoding(UTF-8)', "packets_hercules.txt") or die "Its not possible open input '$!";
open(my $output, '>:encoding(UTF-8)', "output.txt") or die "Its not possible open output $!";
 
print $output "PACKETS HISTORY SINCE 2004
ID = PACKET ID
LEN = PACKET LENGTH 
OPENKORE_SUB = SUB IN OPENKORE THAT PARSE THIS PACKET
PACKET_NAME = PACKET NAME FROM AEGIS ( GRAVITY EMULATOR )
HERCULES_FUNCTION = FUNCTION IN HERCULES EMULATOR THAT PARSE THIS PACKET

ID   LEN  TYPE OPENKORE_SUB                  PACKET_NAME                         HERCULES_FUNCTION\n";

while (my $row = <$input>) {
	if (($row =~ /^\/\/\d+/) || ($row =~ /^\/\/ \d+/)) {
		print $output "\n$row";
	} elsif ($row =~ /packet\(0x([a-zA-Z0-9]{4})\,(-?\d+)/) { # packet(0x0ae7,38,clif->pDull/*,XXX*/);
		
		my $type = "unkn";
		if($packet_list_hercules_recv{lc($1)}[0]) { $type = "recv"; } elsif($packet_list_hercules_send{lc($1)}[0]) {$type = "send";}
		my $openkore_sub = $packet_list_openkore_recv{uc($1)}[0] || $packet_list_openkore_send{uc($1)}[0] || "";
		my $packet_name = $packet_list_hercules_recv{lc($1)}[0] || $packet_list_hercules_send{lc($1)}[0] || "";
		my $hercules_function = $packet_list_hercules_recv{lc($1)}[1] || $packet_list_hercules_send{lc($1)}[1] || "";
		
		printf $output ( "%-4s %-3s %-4s %-30s %-35s %-30s \n", uc($1), $2, $type, $openkore_sub, $packet_name, $hercules_function);
	}
}

# FECHAR INPUT
# FECHAR OUTPUT

print $output "\nBy: alisonrag";

system("pause");