use strict;
use warnings;
use Encode;
 
#Items variables
my ($item_krname, $item_id, %items);

open ITEMS, '<', 'iteminfo.lua';
open COLLECTION, '>:encoding(cp1252)', 'items.txt';
 
while (<ITEMS>) {
    my $line = $_;
    
    if ($line =~ /\[(\d{3,6})\]/) {
        $item_id = $1;
        print "ID: ".$item_id;         
    } elsif($line =~ /\sidentifiedDisplayName = \"(.*)\",/) {      
        $item_krname = $1;
        print " KRNAME: ".$item_krname."\n";
        $items{$item_id} = $item_krname;
    }   
}

close ITEMS;

foreach my $id (sort {$a <=> $b} keys %items) {
	print COLLECTION  $id."#".$items{$id}."\n";
}

close COLLECTION;