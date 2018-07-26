# ============================
# ROItem v.2.0.0
# ============================
# Licensed by hakore (hakore@users.sourceforge.net) under GPL
#
package ROItem;

use strict;
use Globals;
use Exporter;
use base qw(Exporter);
use Settings;
use Log qw(message);
use Translation qw(TF);
#use encoding 'utf8';

our @EXPORT = qw(
   itemNameSimple
   itemName
);

my $datafolder = "$Plugins::current_plugin_folder\\roitem";

my @tables;
my %itemdisplayname;
my %itemslotcount;
my %cardprefixname;
my %cardpostfixname;
my %translations;
my %elementdisplay = (
   1 => 'Ice',
   2 => 'Earth',
   3 => 'Fire',
   4 => 'Wind'#,
   #5 => 'Poison',
   #6 => 'Holy',
   #7 => 'Dark',
   #8 => 'Spirit',
   #9 => 'Undead'
);
my %starcrumbdisplay = (
   1 => 'Very Strong',
   2 => 'Very Very Strong',
   3 => 'Very Very Very Strong'
);
my %cardmultiplier = (
   2 => 'Double',
   3 => 'Triple',
   4 => 'Quadruple'
);

push @tables, Settings::addTableFile(
   "$datafolder\\idnum2itemdisplaynametable.txt",
   loader => [\&parseROLUT, \%itemdisplayname],
   autoSearch => 0);
push @tables, Settings::addTableFile(
   "$datafolder\\itemslotcounttable.txt",
   loader => [\&parseROLUT, \%itemslotcount],
   autoSearch => 0);
push @tables, Settings::addTableFile(
   "$datafolder\\cardprefixnametable.txt",
   loader => [\&parseROLUT, \%cardprefixname],
   autoSearch => 0);
push @tables, Settings::addTableFile(
   "$datafolder\\cardpostfixnametable.txt",
   loader => [\&parseROLUT, \%cardpostfixname],
   autoSearch => 0);
push @tables, Settings::addTableFile(
   "$datafolder\\translations.txt",
   loader => [\&parseTranlations, \%translations],
   autoSearch => 0);

if (defined %config) {
   my $progressHandler = sub {
      my ($filename) = @_;
      Log::message Translation::TF("Loading %s...\n", $filename);
   };
   Settings::loadByRegexp(qr/roitem/, $progressHandler);
}

Plugins::register('ROItem', 'Display item names based on the Ragnarok Online client', \&unload);

my %creators;
my $creators = 0;
my %creatorsX;
my $creatorsX = 0;

my $hooks = Plugins::addHooks(
            ['packet/character_name', \&processCharName],
            ['packet/received_character_ID_and_Map', \&clearCharNameCache]
);

sub unload {
   Plugins::delHooks($hooks);
   foreach (@tables) {
      Settings::removeFile($_);
   }
}

sub parseROLUT {
   my ($file, $r_hash) = @_;

   undef %{$r_hash};
   open FILE, "< $file";
   #open FILE, "<:utf8", $file;
   foreach (<FILE>) {
      s/[\r\n]//g;
      next if (length($_) == 0 || /^\/\//);

      my ($id, $name) = split /#/, $_, 3;
      if ($id) {
         if ($name) {
            $name =~ s/_/ /g;
            $name =~ s/^\s+|\s+$//g;
            $name =~ s/\s+/ /g;
         }
         $r_hash->{$id} = $name;
      }
   }
   close FILE;
   return 1;
}

sub parseTranlations {
   my ($file, $r_hash) = @_;

   %{$r_hash} = ();
   open FILE, "< $file";
   #open FILE, "<:utf8", $file;
   foreach (<FILE>) {
      next if (/^#/);
      s/[\r\n]//g;
      next if (length($_) == 0);

      my ($key, $value) = split /\t+/, $_, 2;
      $r_hash->{$key} = $value;
   }
   close FILE;
   return 1;
}

sub getTranslation {
   my ($str) = @_;
   return $translations{$str} || $str;
}

sub getCreatorName {
   my ($ID, $item) = @_;
   return '' if (!$config{'roItem_showCreatorNames'});
   if (!exists $creators{$ID}) {
      if (!exists $creatorsX{$ID}) {
         $messageSender->sendGetCharacterName($ID);
         $timeout{ai_getInfo}{time} = time;
         $creatorsX{$ID}{time} = time;
         $creatorsX{$ID}{items} = ();
         $creatorsX++;
      }
      $item->{nameless} = 1;
      push @{$creatorsX{$ID}{items}}, $item;
      return getTranslation('Nameless');
   } else {
      return $creators{$ID};
   }
}

sub processCharName {
   my (undef, $args) = @_;
   if (exists $creatorsX{$args->{ID}}) {
      my $nameless = quotemeta getTranslation('Nameless');
      foreach (@{$creatorsX{$args->{ID}}{items}}) {
         if ($config{'roItem_nameFormat'} eq 'bRO') {
            $_->{name} =~ s/ $nameless$/ $args->{name}/;
         } else {
            $_->{name} =~ s/(^| )${nameless}'s /$1$args->{name}'s /;
         }
         delete $_->{nameless};
      }
      delete $creatorsX{$args->{ID}};
      $creatorsX--;
   }
   $creators++ if (!exists $creators{$args->{ID}});
   $creators{$args->{ID}} = $args->{name};
}

sub clearCharNameCache {
   undef %creators;
   $creators = 0;
   undef %creatorsX;
   $creatorsX = 0;
}

# Resolve the name of a simple item
sub itemNameSimple {
   my $ID = shift;
   return 'Unknown' unless defined($ID);
   return 'None' unless $ID;
   return $itemdisplayname{$ID} || "Unknown #$ID";
}

##
# itemName($item)
#
# Resolve the name of an item. $item should be a hash with these keys:
# nameID  => integer index into %items_lut
# cards   => 8-byte binary data as sent by server
# upgrade => integer upgrade level
sub itemName {
   my $item = shift;

   my $name = $itemdisplayname{$item->{nameID}};
   return "Unknown #$item->{nameID}" if (!$name);

   # Resolve item prefix/suffix (carded or forged)
   my $prefix = '';
   my $suffix = '';
   my $type = unpack('v1', $item->{cards});
   my $numSlots = 0;

   if ($type == 254) {
      # Brewed potion
      my $creator = getCreatorName(substr($item->{cards}, 4, 4), $item);
      if ($config{'roItem_nameFormat'} eq 'bRO') {
         $suffix .= (($creator) ? " $creator" : '');
      } else {
         $prefix .= (($creator) ? "${creator}'s " : '');
      }
   } elsif ($type == 255) {
      # Forged weapon
      my ($starcrumb, $creator, $element);
      my $forge = unpack('v1', substr($item->{cards}, 2, 2));
      if (exists $starcrumbdisplay{my $starCrumbs = ($forge >> 8) / 5}) {
         $starcrumb = getTranslation($starcrumbdisplay{$starCrumbs});
      }
      $creator = getCreatorName(substr($item->{cards}, 4, 4), $item);
      if (exists $elementdisplay{my $elementID = $forge % 10}) {
         $element = getTranslation($elementdisplay{$elementID});
      }
      if ($config{'roItem_nameFormat'} eq 'bRO') {
         $suffix .= (($element ne '') ? " $element" : '') .
               (($starcrumb ne '') ? " $starcrumb" : '') .
               (($creator ne '') ? " $creator" : '');
      } else {
         $prefix .= (($starcrumb ne '') ? "$starcrumb " : '') .
               (($creator ne '') ? "${creator}'s " : '') .
               (($element ne '') ? "$element " : '');
      }
   } else {
      my %cards;
      my @cards;
      my $cards = 0;
      for (my $i = 0; $i < 4; $i++) {
         my $cardID = unpack("v1", substr($item->{cards}, $i*2, 2));
         last unless $cardID;
         $cards++;
         push @cards, $cardID if (!$cards{$cardID});
         ($cards{$cardID} ||= 0) += 1;
      }
      if ($cards) {
         # Carded item
         foreach (@cards) {
            if (exists $cardprefixname{$_}) {
               if (exists $cardpostfixname{$_} || $cardprefixname{$_} =~ /^of /) {
                  $suffix .= ' ' . $cardprefixname{$_};
                  $suffix .= ' ' . getTranslation($cardmultiplier{$cards{$_}}) if ($cards{$_} > 1);
               } else {
                  $prefix .= getTranslation($cardmultiplier{$cards{$_}}) . ' ' if ($cards{$_} > 1);
                  $prefix .= $cardprefixname{$_} . ' ';
               }
            }
         }
      } elsif ($item->{type} == 4 && unpack('v1', substr($item->{cards}, 6, 2)) == 1) {
         $prefix .= getTranslation('Beloved') . ' ';
      }
      $numSlots = $itemslotcount{$item->{nameID}};
   }


   my $display = "";
   $display .= getTranslation('BROKEN') . ' ' if ($item->{broken});
   $display .= "+$item->{upgrade} " if ($item->{upgrade});
   $display .= $prefix . $name . $suffix;
   $display .= " [$numSlots]" if ($numSlots);

   return $display;
}

# ============================
# Misc.pm Override Functions
# ============================
# Licensed by hakore (hakore@users.sourceforge.net) under GPL
#
package Misc;

use strict;

sub itemNameSimple {
   return ROItem::itemNameSimple(shift);
}

sub itemName {
   return ROItem::itemName(shift);
}
# re use Misc everywhere so the new function is used

package main;
use Misc;
package Commands;
use Misc;
package Network::Receive;
use Misc;

return 1;