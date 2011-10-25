# NoinkLib.pm
# -----------
# Noink Common Library API
# - Part of the new and improved Noink API for 1.x releases
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

#################################################################################
# no_SectionBegin($width, $thickness, $bgcolor)
# -----------------
# Creates an entirely new section of the page (essentially a table)
# -----------------
# Optional Parameter:
#	$width : width of the section (percentage of screen/table or pixels)
#	$thickness : thickness of spacing (invisible borders)
#	$bgcolor : Background color of section
# Returns: Nothing
#------------------
sub no_SectionBegin {
	my ($width, $thickness, $bgcolor) = @_;
	
	print "<table";
	if($width) {
		print " width=\"$width\"";
	}
	if($thickness) {
		print " cellspacing=\"$thickness\" cellpadding=\"$thickness\"";
	} else {
		print " cellspacing=\"0\" cellpadding=\"0\""
	}
	if($bgcolor) {
		print " bgcolor=\"$bgcolor\"";
	}
	print "><tr><td>\n";
}

#################################################################################
# no_SectionEnd()
# -----------------
# Ends a section fully
# -----------------
# No paramters, no returns
#------------------
sub no_SectionEnd {
	print "</td></tr></table>\n";
}

#################################################################################
# no_SectionNewCol()
# ------------------
# Starts a new column in the given section
# ------------------
# No parameters, no retruns
#-------------------
sub no_SectionNewCol {
	print "</td><td>\n";
}

#################################################################################
# no_SectionNewRow()
# ------------------
# Starts a new row in the given section
# ------------------
# No parameters, no returns
#-------------------
sub no_SectionNewRow {
	print "</td></tr><tr><td>\n";
}

#################################################################################
# no_BoxStart($width, $thickness, $boxColor, $innerColor, $borderColor, $HTML)
# -----------------
# Creates a box top in the style of boxes in Noink 1.x
# -----------------
# Parameters:
#	$width : Width of the box (percentage of screen/table or pixels)
#	$thickness : Thickness of the box's border (in pixels) - integer
#	$boxColor : Color of the box (in hex)
#	$innerColor : Color of the inside of the box (in hex)
# Optional Parameters:
#	$borderColor : If defined, will be the color of a single pixel
#			thick border around the box
#	$HTML : If defined, then will place any code it is given in the
#		top of the box
# Returns: Nothing
#------------------
sub no_BoxStart {
	my ($width, $thickness, $boxColor, $innerColor, $borderColor, $HTML) = @_;
	
	# Create border if defined
	if($borderColor) {
		print "<table bgcolor=\"$borderColor\" cellpadding=\"1\" cellspacing=\"1\"";
		if($width) {
			print " width=\"$width\"";
		}
		print "><tr><td>\n";
	}
	
	# Box Border
	print "<table";
	if($width) {
		print " witdh=\"$width\"";
	}
	if($boxColor) {
		print " bgcolor=\"$boxColor\"";
	}
	if($thickness) {
		print " cellspacing=\"$thickness\" cellpadding=\"$thickness\"";
	} else {
		# Default at thickness of 1 pixel
		print " cellspacing=\"1\" cellpadding=\"1\"";
	}
	print "><tr><td>\n";
	if($HTML) {
		print "$HTML\n";
	}
	
	# Inner Box
	print "</td></tr><tr><td><table";
	if($innerColor) {
		print " bgcolor=\"$innerColor\"";
	}
	print "><tr><td>\n";
}

#################################################################################
# no_BoxEnd($borderColor, $HTML)
# -----------------
# Creates a box bottom in the style of boxes in Noink 1.x
# -----------------
# Optional Parameters:
#	$borderColor : If defined, will be the color of a single pixel
#			thick border around the box
#	$HTML : If defined, then will place any code it is given in the
#		bottom of the box
# Returns: Nothing
#------------------
sub no_BoxEnd {
	my ($borderColor, $HTML) = @_;
	
	# End ther Inner Box
	print "</td></tr></table>\n";
	
	# End the Box
	if($HTML) {
		print "</td></tr><tr><td>\n$HTML\n";
	}
	print "</td></tr></table>\n";
	
	# End the Border
	if($borderColor) {
		print "</td></tr></table>\n";
	}
}

#################################################################################
# no_private_borderstart(@params)
# ----------------------------
# Semi-private function which is nothing more than a wrapper for other functions
# ----------------------------
# Required Params:
#	@params : The list of params (invalid ones ignored)
# Returns: Nothing
#-----------------------------
sub no_private_borderstart {
	undef $thick_;
	undef $bdcolor_;
	undef $bgcolor_;
	undef $frcolor_;
	undef $padding_;
	foreach $param (@_) {
		## HERE I AM JH
	}
}

#################################################################################
# no_ParseNOI($NOIversion, %NOIhash)
# --------------------------------------
# Parses a NoML (NOI) file post 1.x version. Please note that the version is
# required, and if no valid version is specified, the default is the current
# (most recent) version.
# --------------------------------------
# Required Parameters:
# 	$NOIversion : The version of the NoML (NOI) file format used
# 	%NOIhash : The hash containing the NoML (NOI) file after sorting
# Returns: Nothing
#------------------
sub no_ParseNOI {
	my ($NOIversion, %NOIhash) = @_;
	my $line = "";
	
	if($NOIversion =~ m/1.4/) {
		print "What the?";
	} else {
		# The default is 1.2, or the version to be released with the 1.2.x release (1.1.x developmental)
		my @layout = ml_GetElements($noml_layout, %NOIhash);
		
		#Parse the layout
		foreach $line (@layout) {
			if($line =~ m/!/) {
				# A `!' char means the line is a command (!cmd)
				my @cmd_line = split(/$conf_space/, $line);
				if($cmd_line[0] =~ m/$noml_layoutcmd_borderstart/) {
					no_private_borderstart(@cmd_line);
				} elsif {$cmd_line[0] =~ m/$noml_layoutcmd_borderend/) {
					no_private_borderend(@cmd_line);
				} elsif ($cmd_line[0] =~ m/$noml_layoutcmd_newline/) {
					no_private_newline(@cmd_line);
				}
			}
		}
	}
}

1;
