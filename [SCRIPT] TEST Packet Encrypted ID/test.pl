package Network::XKoreProxy;

use strict;
use Math::BigInt;
# 0x230959EB,0x1CCB0182,0x1FFA2B30
my $crypt1 = Math::BigInt->new(0x230959EB);
my $crypt3 = Math::BigInt->new(0x1CCB0182);
my $crypt2 = Math::BigInt->new(0x1FFA2B30);

for (my $i=0; $i<20; $i++) {
my $r_message = pack("C*",0x7d, 0x11, 0xB3, 0x75, 0xA0, 0x00, 0x2C, 0x57, 0x02, 0x00, 0x10, 0x2B, 0xD8, 0xF0, 0x0E, 0x20, 0x56, 0x05, 0x00);
my $messageID = unpack("v", $r_message);

# Saving Last Informations for Debug Log
my $oldMID = $messageID;
my $oldKey = ($crypt1 >> 16) & 0x7FFF;

# Calculating the Encryption Key
$crypt1 = ($crypt1 * $crypt3 + $crypt2) & 0xFFFFFFFF;

# Xoring the Message ID
$messageID = ($messageID ^ (($crypt1 >> 16) & 0x7FFF)) & 0xFFFF;

# Debug Log
printf("Decrypted MID : [%04X]->[%04X] / KEY : [0x%04X]->[0x%04X]\n", $oldMID, $messageID, $oldKey, ($crypt1 >> 16) & 0x7FFF);
}

1;
