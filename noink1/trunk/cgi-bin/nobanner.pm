# nobanner.pm
# -----------
# Contains the noink banner library
#
#    Copyright (C) 2000 Sam Hart
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

##########################
# BannerDisplay - Main
# sub for banner stuff
# (Presently only includes
# may do other things and
# even have its own config
# file later on)
##########################
sub BannerDisplay {
	# This is /very/ QND, I will do something more profound and meaningful later on
	#HELL, we don't even check to verify this file exists!
	
	#Alright, here again is such a kludge... I apologize... will massage into something
	#more useful later.... just want it to work right off the bat with NoNews...
	if(! $banner_file{$root}) {
		$root = 'bogus';
		$banner_file{$root} = $location_banner;
	}
	
	open(BANNER, "$banner_file{$root}");
	@banner_content = <BANNER>;
	close BANNER;
	
	print "\n\n<center>";
	foreach $s (@banner_content) {
		print "$s\n";
	}
	print "</center>\n\n";
	
	#we're even centering the thing by default!!! Poor show good man!
}

1;
