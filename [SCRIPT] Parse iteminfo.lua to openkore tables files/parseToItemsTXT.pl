use strict;
use warnings;
use Encode;

#Items variables
my ($item_krname, $item_id);

open ITEMS, '<', 'itemInfo.txt';
open COLLECTION, '>', 'idnum2resnametable.txt';

while (<ITEMS>) {
	my $line = $_;
	
	if ($line =~ /\[(\d+)\]/) {
		$item_id = $1;
		print "ID: ".$item_id;
		
	} elsif($line =~ /identifiedResourceName = \"(.*)\",/) {		
		$item_krname = encode("euc-kr", $1);
		
		print " KRNAME: ".$item_krname."\n";
		print COLLECTION "$item_id"."#".$item_krname."\n";
	}	
}
close ITEMS;
close COLLECTION;
