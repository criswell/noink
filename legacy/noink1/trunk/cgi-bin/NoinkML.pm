# NoinkML.pm
# noink markup language API
# ------------------------------
#
#    Copyright (C) 2001 Sam Hart
#
#    This library is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser General Public
#    License as published by the Free Software Foundation; either
#    version 2.1 of the License, or (at your option) any later version.
#
#    This library is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public
#    License along with this library; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

######################################################################################
# Assumed Globals for the Noink Libraries :
# (Not all globals are needed for all functions- see individual functions for details)
#-------------------------------------------------------------------------------------
# %Config : Config NoML hash as loaded by ml_ParseML or ml_ParseML_PreLoaded
# $noCGI : An instance of class CGI (from CGI.pm)

########################
# GetElements : Given an
# NoML hash index key,
# will obtain and return
# the elements the NoML
# hash contains
########################
sub ml_GetElements {
	my ($key, %xmlhash) = @_;
	my @temphash = @xmlhash{$key};
	my @elementlist = ();
	$#elementlist = -1;
	foreach $i (@temphash) {
		for($l = 0; $l <= $#$i; $l++) {
			push (@elementlist, $i->[$l]);
		}
	}
	return (@elementlist);
}

########################
# GetElement : Given an
# NoML hash index key,
# will obtain and return
# a single element from
# the hash. Will always
# return the first non-
# blank element
########################
sub ml_GetElement {
	my ($key, %xmlhash) = @_;
	my @temphash = @xmlhash{$key};
	undef $element;
	foreach $i (@temphash) {
		for($l = 0; $l <= $#$i; $l++) {
			if($i->[$l] ne "") {
				$element = $i->[$l];
			}
		}
	}
	return ($element);
}

########################
# PutElements : Given an
# element, an NoML hash
# index key, and the
# dest. hash, will
# insert the element in
# the hash, overriding
# the original elements
########################
sub ml_PutElement {
	my ($new_element, $key, %xmlhash) = @_;
	my @temphash = @xmlhash{$key};
	my $count_guy = 0;
	foreach $i (@temphash) {
		for($l = 0; $l <= $#$i; $l++) {
			if($count_guy == 0) {
				$i->[$l] = $new_element;
				$count_guy++;
			} else {
				$i->[$l] = "";
			}
		}
	}
	return %xmlhash;
}

###########################
# PutNewElements : Given an
# element, an NoML hash
# index key, and the
# dest. hash, will
# insert the element in
# the hash, overriding
# the original elements
# (Original element need
# not exist)
###########################
sub ml_PutNewElement {
	my ($new_element, $key, %xmlhash) = @_;

	$xmlhash{$key}[0] = $new_element;
	return %xmlhash;
}

###########################
# AddNewElement ; Will add
# the given element to a
# xml hash
###########################
sub ml_AddNewElement {
	my ($new_element, $key, %xmlhash) = @_;
	
	my @org_array = GetElements($key, %xmlhash);
	push(@org_array, $new_element);
	
	for($i = 0; $i <= $#org_array; $i++) {
		$xmlhash{$key}[$i] = $org_array[$i];
	}

	return %xmlhash;
}

###########################
# ReplaceElements ; Will
# replace the elements in a
# xml hash
###########################
sub ml_ReplaceElements {
	my ($key, @new_array, %xmlhash) = @_;
	
	my @org_array = GetElements($key, %xmlhash);
	
	for($i = 0; $i <= $#new_array; $i++) {
		$xmlhash{$key}[$i] = $new_array[$i];
	}
	
	if($#org_array > $#new_array) {
		my $diff = $#org_array - $#new_array;
		for($i = 0; $i <= $diff; $i++) {
			$xmlhash{$key}[$i] = "";
		}
	}

	return %xmlhash;
}

########################
# Obtain the keys of
# a particular NoML hash
########################
sub ml_GetKeys {
	my (%xmlhash) = @_;
	my @keys = ();
	$#keys = -1;
	#Sort the keys!

	foreach $key (keys %xmlhash) {

		push (@keys, $key);
	}
	
	return sort @keys;
}

#######################
# FilterKeys
#######################
sub ml_FilterKeys {
	my ($filter, @keys) = @_;
	foreach ($filter, @keys) {
		#Strip off extra spaces
		s/^\s+//;
		s/\s+$//;
		#Strip off extra newlines
		s/^\n+//;
		s/\n+$//;
	}
	my @filarray = split(/\./, $filter);
	if($#filarray == -1) {
		#in case we are at depth 1
		$filarray[0] = $filter;
	}
	my @filtered = ();
	#ensure that all depth 0 ones are there
	
	foreach $keylin (@keys) {

		my @keyarr = split(/\./, $keylin);

		if($#keyarr == -1) {
			#in case we are at depth 1
			$keyarr[0] = $keylin;
		}
		my $test = 0;
		foreach $d (@filtered) {
			if($d eq $keyarr[0]) {
				$test++;
			}
		}
		if($test == 0) {
			push(@filtered, $keyarr[0]);
		}
	}
	
	foreach $keylin (@keys) {
		my @keyarr = split(/\./, $keylin);
		if($#keyarr == -1) {
			#in case we are at depth 1
			$keyarr[0] = $keylin;
		}
		my $test1 = 0;
		my @testline = ();
		$#testline = -1;
		for($i = 0; $i <= $#keyarr; $i++) {
			if($filarray[$i] eq $keyarr[$i]) {
				$test1++;
				push(@testline, $keyarr[$i]);
			}
		}
		if($test1 == $#keyarr) {
			$testline_fin = join(".", @testline);
		
			my $test = 0;
			foreach $d (@filtered) {
				if($d eq $testline_fin) {
					$test++;
				}
			}
			if($test == 0) {
				push(@filtered, $testline_fin);
			}
		}
	}
	if($#filarray > -1) {
		#We are at some arbitrary level in the XML tree
		foreach $keylin (@keys) {
			my @keyarr = split(/\./, $keylin);
			if($#keyarr >= $#filarray) {
				#must be deeper than filter!
				my $test = 0;
				for($i = 0; $i <= $#filarray; $i++) {
					if($keyarr[$i] eq $filarray[$i]) {
						$test++;
					}
				}
				if($test == ($#filarray+1)) {
					my $test2 = 0;
					my $testfilter = "";
					foreach $d (@filtered) {
						if($keyarr[$#filarray+1] eq "") {
							$testfilter = "$filter";
						} else {
							$testfilter = "$filter.$keyarr[$#filarray+1]"
						}
						if($d eq $testfilter) {
							$test2++;
						}
					}
					if($test2 == 0) {
						if($keyarr[$#filarray+1] eq "") {
							$testfilter = "$filter";
						} else {
							$testfilter = "$filter.$keyarr[$#filarray+1]"
						}
						push(@filtered, $testfilter);
					}
				}
			}
		}
	}
	
	return sort @filtered;
}

##############################
# SaveXMLFile: Save the given
# XML hash to the file
# specified. Note: This does
# not produce human readable
# XML code!
##############################
sub ml_SaveMLFile {
	my ($filename, %xmlhash) = @_;
	my @xml_keys = GetKeys(%xmlhash);
	open (XMLOUT, ">$filename");
	foreach $keyline (@xml_keys) {
		my @key = split(/\./, $keyline);
		#Do the pre-data work
		foreach $sub_sect (@key) {
			if($sub_sect ne "") {
				print XMLOUT "<$sub_sect>\n";
			}
		}
		#Do the data (yeah, baby)
		my @data = GetElements($keyline, %xmlhash);
		foreach $data_line (@data) {
			print XMLOUT "$data_line\n";
		}
		#Do the post-data work
		for($i = $#key; $i >= 0; $i--) {
			if($key[$i] ne "") {
				print XMLOUT "</$key[$i]>\n";
			}
		}
	}
	close XMLOUT;
	#We out
}

##############################
# ParseXML_PreLoaded - If the
# XML file is already loaded
# and we simply wish to parse
# it, this can be used.
# Also used by ParseXML to
# do the actual parsing (in
# that respect, I suppose we
# picked inappropriate names,
# huh?)
##############################
sub ml_ParseML_PreLoaded {
	my (@xmlsrc) = @_;
	my %xmlhash = ();
	my $xmlline = "";
	my @xmlarray = ();
	my @temp = ();
	my $line = "";
	my $section = "";
	
	foreach (@xmlsrc) {
		#Strip off extra spaces
		s/^\s+//;
		s/\s+$//;
		#Strip off extra newlines
		s/^\n+//;
		s/\n+$//;
	}
	
	%xmlhash = ();
	$xmlline = "";
	$#xmlarray = -1;
	$#temp = -1;
	
	#Parse the XML file
	foreach $line (@xmlsrc) {
			
		if($line =~ m|<| & $line !~ m|</|) {
			#A section has just begun
			$section = $line;
			$section =~ s/<//;
			$section =~ s/>//;
			$xmlstring = join (".",@xmlarray);
				
			for($i = 0; $i<=$#temp; $i++) {
				$xmlhash{$xmlstring}[$i] = $temp[$i];
			}
			push (@xmlarray, $section);
			$#temp = -1;
		} elsif($line =~ m|</|) {
			#A section has just ended
			$section = $line;
			$section =~ s|</||;
			$section =~ s|>||;
			#Was the section ending correct?
			if($xmlarray[$#xmlarray] eq $section) {
				#Yes? good
				$xmlstring = join (".",@xmlarray);
				
				for($i = 0; $i<=$#temp; $i++) {
					$xmlhash{$xmlstring}[$i] = $temp[$i];
				}
				pop(@xmlarray);
				$#temp = -1;
				$xmlstring = join (".",@xmlarray);
				
				@temphash = @xmlhash{$xmlstring};
				foreach $i (@temphash) {
					for($l = 0; $l <= $#$i; $l++) {
						push(@temp, $i->[$l]);
					}
				}
			} else {
				#XML tree error, element does not match!
				$xmlstring = join (".",@xmlarray);
				#Well make this one an error entry
				$xmlstring = "$xmlstring.ERROR";
				
				for($i = 0; $i<=$#temp; $i++) {
					$xmlhash{$xmlstring}[$i] = $temp[$i];
				}
				
				#Note, what we are doing next will cause /real/ problems if your XML
				#file is fubar'ed!
				pop(@xmlarray);
				$#temp = -1;
				$xmlstring = join (".",@xmlarray);
				
				@temphash = @xmlhash{$xmlstring};
				foreach $i (@temphash) {
					for($l = 0; $l <= $#$i; $l++) {
						push(@temp, $i->[$l]);
					}
				}
			}
			
		} else {
			push (@temp, $line);
		}
	}
	return %xmlhash;
}

#####################
# ParseXML - Load and
# parse a simple XML
# config file
#####################
sub ml_ParseML {
	my ($xmlfile) = @_;
	my %xmlhash = ();
	my $xmlline = "";
	my @xmlarray = ();
	my @temp = ();
	my @xmlsrc = ();
	my $line = "";
	my $section = "";
	
	#Let's try to open the file
	if(open(XMLSRC, "$xmlfile")) {
		@xmlsrc = <XMLSRC>;
		close XMLSRC;
		%xmlhash = ParseXML_PreLoaded(@xmlsrc);
	} else {
		$xmlhash{ERROR} = "The file \"$xmlfile\" does not exist!";
	}
	
	return %xmlhash;
}

1;