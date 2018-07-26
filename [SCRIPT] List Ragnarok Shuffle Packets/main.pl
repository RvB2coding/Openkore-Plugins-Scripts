#!/usr/bin/env/perl
use strict;use warnings;use Switch;
system("cls");
my $lines;my $servers_found = 0;my $last = "[unknown]";my %data;my $cnt;
my (%two,%three,%four,%five,%six,%seven,%eight) = (); 
my $result = open_file("output.txt");

use constant { 
CMSG_MAP_SERVER_CONNECT => "map_login", CMSG_SKILL_USE_POSITION => "skill_use_location", CMSG_SOLVE_CHAR_NAME => "actor_name_request", CMSG_SKILL_USE_BEING => "skill_use", CMSG_PLAYER_INVENTORY_DROP  => "item_drop", CMSG_ITEM_PICKUP => "item_take", CMSG_BUYINGSTORE_OPEN => "buy_bulk_request", CMSG_BUYINGSTORE_CLOSE => "buy_bulk_closeShop", CMSG_BUYINGSTORE_SELL => "buy_bulk_buyer", CMSG_BUYINGSTORE_CREATE => "buy_bulk_openShop", CMSG_ITEM_LIST_WINDOW_SELECT => "item_list_window_selected", CMSG_FRIENDS_ADD_PLAYER => "friend_request", CMSG_MAP_SERVER_CONNECT => "map_login", CMSG_MAP_PING => "sync", CMSG_PLAYER_CHANGE_DEST => "character_move", CMSG_HOMUNCULUS_MENU => "homunculus_command", CMSG_PLAYER_CHANGE_DIR => "actor_look_at", CMSG_MOVE_TO_STORAGE => "storage_item_add", CMSG_PARTY_INVITE2 => "party_join_request_by_name", CMSG_NAME_REQUEST => "actor_info_request", CMSG_PLAYER_CHANGE_ACT => "actor_action", CMSG_STORAGE_PASSWORD => "storage_password", CMSG_MOVE_FROM_STORAGE => "storage_item_remove",
};

exit(0) if ($result eq 0);
read_file();close_file();read_hash();print"\n\n";system("pause");
my %outputs = ();#make_tag_outputs();

sub make_tag_outputs {
	open G, ">>outputs.txt";
	foreach (keys %outputs) {
		print G "$_\n";
	}
	close(G);
}


sub open_file {
my ($input, $filename);$filename = shift;open $input, "<$filename" or return 0;return $input;
}
sub close_file {close($result);}
sub read_file {
my ($packet, $tmp1, $tmp2, $tmp3) = "[unknown]";
	while (<$result>) {
		$lines = $_;next if ($lines =~ /^\*|\/\/|\/\*|^#/ig);
			if ($lines =~ /^if\s+\(packetVersion .. (\d+)\)/ig) {
				$tmp1 = $1;
					if ($tmp1 =~ /^((2012|2013|2014|2015|2016|2017|2018).*)/i) { 
						$last = "[$1]";$servers_found += 1;$tmp2 = $2;
						if (!($data{$last})) {
							$data{$last} = "1";
						}
					}
			}
			if ($lines =~ /packet\((.*),\s+(0x....)\,\s+(-)?\d+\,\s+clif->(.*)\);/ig) {
			next if ($last eq "[unknown]");$packet = $2;$tmp3 = $1;
				switch ($tmp3) {
					case qr/CMSG_MAP_SERVER_CONNECT.*/ {add_to_hash($last, $packet, CMSG_MAP_SERVER_CONNECT , $tmp2)}
					case qr/CMSG_MOVE_FROM_STORAGE.*/ { add_to_hash($last, $packet, CMSG_MOVE_FROM_STORAGE , $tmp2) }
					case qr/CMSG_MAP_PING.*/ { add_to_hash($last, $packet, CMSG_MAP_PING , $tmp2) }
					case qr/CMSG_PARTY_INVITE2.*/ { add_to_hash($last, $packet, CMSG_PARTY_INVITE2 , $tmp2) }
					case qr/CMSG_PLAYER_CHANGE_ACT.*/ { add_to_hash($last, $packet, CMSG_PLAYER_CHANGE_ACT , $tmp2) }
					case qr/CMSG_HOMUNCULUS_MENU.*/ { add_to_hash($last, $packet, CMSG_HOMUNCULUS_MENU , $tmp2) }
					case qr/CMSG_PLAYER_CHANGE_DIR.*/ { add_to_hash($last, $packet, CMSG_PLAYER_CHANGE_DIR , $tmp2) }
					case qr/CMSG_PLAYER_INVENTORY_DROP.*/ { add_to_hash($last, $packet, CMSG_PLAYER_INVENTORY_DROP , $tmp2) }
					case qr/CMSG_SKILL_USE_POSITION.*/ { add_to_hash($last, $packet, CMSG_SKILL_USE_POSITION , $tmp2) }
					case qr/CMSG_NAME_REQUEST.*/ { add_to_hash($last, $packet, CMSG_NAME_REQUEST , $tmp2) }
					case qr/CMSG_STORAGE_PASSWORD.*/ { add_to_hash($last, $packet, CMSG_STORAGE_PASSWORD , $tmp2) }
					case qr/CMSG_SOLVE_CHAR_NAME.*/ { add_to_hash($last, $packet, CMSG_SOLVE_CHAR_NAME , $tmp2) }
					case qr/CMSG_PLAYER_CHANGE_DEST.*/ { add_to_hash($last, $packet, CMSG_PLAYER_CHANGE_DEST , $tmp2) }
					case qr/CMSG_MOVE_TO_STORAGE.*/ { add_to_hash($last, $packet, CMSG_MOVE_TO_STORAGE , $tmp2) }
					case qr/CMSG_SKILL_USE_BEING.*/ { add_to_hash($last, $packet, CMSG_SKILL_USE_BEING , $tmp2) }
					case qr/CMSG_FRIENDS_ADD_PLAYER.*/ { add_to_hash($last, $packet, CMSG_FRIENDS_ADD_PLAYER , $tmp2) }
					case qr/CMSG_ITEM_PICKUP.*/ { add_to_hash($last, $packet, CMSG_ITEM_PICKUP , $tmp2) }
					case qr/CMSG_BUYINGSTORE_OPEN.*/ { add_to_hash($last, $packet, CMSG_BUYINGSTORE_OPEN , $tmp2) }
					case qr/CMSG_BUYINGSTORE_CLOSE.*/ { add_to_hash($last, $packet, CMSG_BUYINGSTORE_CLOSE , $tmp2) }
					case qr/CMSG_BUYINGSTORE_SELL.*/ { add_to_hash($last, $packet, CMSG_BUYINGSTORE_SELL , $tmp2) }
					case qr/CMSG_BUYINGSTORE_CREATE.*/ { add_to_hash($last, $packet, CMSG_BUYINGSTORE_CREATE , $tmp2) }
					case qr/CMSG_ITEM_LIST_WINDOW_SELECT.*/ { add_to_hash($last, $packet, CMSG_ITEM_LIST_WINDOW_SELECT , $tmp2) }
					#case qr/CMSG_SKILL_USE_POSITION_MORE.*/ { add_to_hash($last, $packet, CMSG_SKILL_USE_POSITION_MORE , $tmp2) }
					#case qr/CMSG_SEARCHSTORE_CLICK.*/ { add_to_hash($last, $packet, CMSG_SEARCHSTORE_CLICK , $tmp2) }
					#case qr/CMSG_SEARCHSTORE_SEARCH.*/ { add_to_hash($last, $packet, CMSG_SEARCHSTORE_SEARCH , $tmp2) }
					#case qr/CMSG_SEARCHSTORE_NEXT_PAGE.*/ { add_to_hash($last, $packet, CMSG_SEARCHSTORE_NEXT_PAGE , $tmp2) }
					#case qr/CMSG_BOOKING_REGISTER_REQ.*/ { add_to_hash($last, $packet, CMSG_BOOKING_REGISTER_REQ , $tmp2) }
			}
				$outputs{$tmp3} = "1" if (%outputs && !$outputs{$tmp3});
			}	
	}
}

sub add_to_hash {
my ($key, $packet, $value, $tmp) = @_;

$two{"$key-$value"} = "$packet" if ($tmp =~ /2012/);
$three{"$key-$value"} = "$packet" if ($tmp =~ /2013/);
$four{"$key-$value"} = "$packet" if ($tmp =~ /2014/);
$five{"$key-$value"} = "$packet" if ($tmp =~ /2015/);
$six{"$key-$value"} = "$packet" if ($tmp =~ /2016/);
$seven{"$key-$value"} = "$packet" if ($tmp =~ /2017/);
$eight{"$key-$value"} = "$packet" if ($tmp =~ /2018/);
$cnt += 1 if ($value eq "map_login");
}
#two
sub read_hash {
foreach (sort keys %two) {
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
mkdir "Send_packet";
mkdir "Send_packet/12";
mkdir "Send_packet/13";
mkdir "Send_packet/14";
mkdir "Send_packet/15";
mkdir "Send_packet/16";
mkdir "Send_packet/17";
mkdir "Send_packet/18";

$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/12/$temp1.txt";
				$text = uc($two{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
#three
foreach (sort keys %three) {
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/13/$temp1.txt";
				$text = uc($three{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
#four
foreach (sort keys %four) {    
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/14/$temp1.txt";
				$text = uc($four{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
#five
foreach (sort keys %five) {    
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/15/$temp1.txt";
				$text = uc($five{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
#six
foreach (sort keys %six) {    
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/16/$temp1.txt";
				$text = uc($six{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
#seven
foreach (sort keys %seven) {    
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/17/$temp1.txt";
				$text = uc($seven{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
#eight
foreach (sort keys %eight) {    
my $temp1 = $_;
my $temp2 = 0;
my $temp3 = $_;
my $temp4 = $_;
my $temp5 = $temp3;
$temp5 =~ s/\[(.*)\]-(.*)/$2/ig;
$temp1 =~ s/(.*)-(.*)/$1/ig;
my $text;
	foreach (sort keys %data) {
	$temp2 = $_;
		if ($temp1 eq $temp2) {
			open F, ">>Send_packet/18/$temp1.txt";
				$text = uc($eight{$temp3}). " => $temp5\n";
				$text =~ s/X/x/g;
				print F $text;
			close(F);
		}
	}
}
	print "$cnt map login packets found in 2015 serverType list\n";
	print "$servers_found servers found between 2012 and 2018\n";
}