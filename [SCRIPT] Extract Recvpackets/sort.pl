use strict;
use warnings;
use Encode;

my %packets;
my $packetid;

open ITEMS, '<', 'recvpackets.txt';
while (<ITEMS>) {
    my $line = $_;
   
   if ($line =~ /(\S+) (-?\d+)/) {
      undef $packetid;
      $packetid = uc($1);
      if (!exists($packets{$packetid})) {
         $packets{$packetid} = $2;
      }
   }
}
close ITEMS;

open F2, ">recvpackets.txt";
foreach my $value (sort keys %packets) {
   print F2 "$value $packets{$value}\n";
}

close F2;

print "Done.\n";
system("pause");