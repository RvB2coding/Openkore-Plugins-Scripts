#!/usr/bin/env/perl
use strict;
use warnings;
use Packets;

open(my $input, '<:encoding(UTF-8)', "packets_hercules.txt") or die "Its not possible open input '$!";
open(my $output, '>:encoding(UTF-8)', "output.txt") or die "Its not possible open output $!";
 
while (my $row = <$input>) {
	if (($row =~ /^\/\/\d+/) || ($row =~ /^\/\/ \d+/)) {
		print $output "\n$row";
	} elsif ($row =~ /packet\(0x([a-zA-Z0-9]{4})\,(\d+)/) { # packet(0x0ae7,38,clif->pDull/*,XXX*/);
		#printf( "%-4s %-3s %-", "hello" );
		print $output uc($1)."\t".$2."\t".$packet_list_openkore{uc($1)}[0]."\t\t\t\t\t\t\t".$packet_list_hercules{uc($1)}[0]."\t\t\t\t".$packet_list_hercules{uc($1)}[1]."\n";
	}
}
# PACKET_ID	LENGTH	OPENKORE_FUNCTION	NAME	HERCULES_FUNCTION

# FECHAR INPUT
# FECHAR OUTPUT


system("pause");