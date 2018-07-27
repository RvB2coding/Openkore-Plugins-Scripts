#!/usr/bin/perl
use strict;
use warnings;
use autodie; # die if problem reading or writing a file
use Cwd;

my $dir = getcwd;

opendir(DIR, $dir) or die $!;

while (my $file = readdir(DIR)) {
	
	# Use a regular expression to ignore files beginning with a period
	next if ($file =~ m/^\./);
	my $str = $file;
	my $find = "_";
	my $replace = " ";
	$find = quotemeta $find; # escape regex metachars if present
	
	$str =~ s/$find/$replace/g;
	
	
	rename($file, $str);

print "$file to $str\n";

}

closedir(DIR);
exit 0;