# NoinkAdmin.pm
# -----------
# Noink Aministration Library API
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
 

#########################################################################
# VERSION 1.x FUNCTIONS : The following functions comprise the new
# Noink 1.x Admin API. These are intended to replace their counterparts
# from the previous versions. They are to be general purpose ones for
# use in any future Noink extensions.

##########################################
# Admin_LoginBox :
# Displays a formated login box.
#---------------------
# Input Params:
# ($LoginCGI, $NewUserCGI, $PassForgetCGI,
# $Title, $PreText, $LoginButton,
# $ResetButton, $PostText, $NewUserText,
# $PassForgetText, $LoggedPreText)
#
# - $LoginCGI : The fully qualified path
# for the Login link to link to.
#
# - $NewUserCGI : The fully qualified path
# for the New User link to link to.
#
# - $PassForgetCGI : The fully qualified
# path for the "Forgotten Password" link
# to link to.
#
# - $Title : Title text for top of box
#
# - $PreText : Any and all Text to display
# before the login fields.
#
# - $LoginButton : Text inside Login Butn
#
# - $ResetButton : Text inside Reset Butn
#
# - $PostText : Any and all Text to display
# after the login fields
#
# - $NewUserText : The text as a part of
# the link for New User creation
#
# - $PassForgetText : The text for the link
# for forgotten password link
#
# - $LoggedPreText : Text to be displayed
# when the user is logged in, before their
# name
#---------------------
# Return Params : None
#---------------------
# Needed Globals:
# - %Config : Current config using v1.x
# format.
# - %User : Current user logged in, if any
# also needs v1.x format
###########################################
sub Admin_LoginBox {
	my ($LoginCGI, $NewUserCGI, $PassForgetCGI, $Title, $PreText, $LoginButton, $ResetButton, $PostText, $NewUserText, $PassForgetText, $LoggedPreText) = @_;
	my $fontface = GetElement("${Theme}.${noml_LoginBox}.${noml_fontface}", %Config);
	
	my $bord_w = GetElement("${Theme}.${noml_LoginBox}.${noml_borderw}", %Config);
	my $bord_c = GetElement("${Theme}.${noml_LoginBox}.${noml_borderc}", %Config);
	my $backg_c = GetElement("${Theme}.${noml_LoginBox}.${noml_bgcolor}", %Config);
	my $text_c = GetElement("${Theme}.${noml_LoginBox}.${noml_textcolor}", %Config);
	my $bord_text_c = GetElement("${Theme}.${noml_LoginBox}.${noml_bordertextcolor}", %Config);
	print "<table ";
	if($bord_w) {
		print " bgcolor=\"$bord_c\" CELLSPACING=\"0\" CELLPADDING=";
		my $cel_pad = $bord_w - 1;
		print "\"$cel_pad\" ";
		my $temp_w = GetElement("${Theme}.${noml_LoginBox}.$noml_width", %Config);
		print "WIDTH=\"$temp_w\"  BORDER=\"0\" ><TR><TD>\n";
		
		print "<font size=+2 ";
		if($fontface) {
			print "face=\"$fontface\" ";
		}
		if($bord_text_c) {
			print "color=\"$bord_text_c\" ";
		}
		print ">$Title</font></td></tr><tr><td>\n";
		
		print "<table ";
		if($backg_c) {
			print " bgcolor=\"$backg_c\" ";
		}
		print "CELLSPACING=\"0\" CELLPADDING=\"$bord_w\" WIDTH=";
		print "\"100%\"  BORDER=\"0\"";
	} else {
		foreach $tag (@Table_metas) {
			my $temp_t = GetElement("${Theme}.${noml_LoginBox}.${tag}", %Config);
			if($temp_t) {
				print " $tag=\"$temp_t\" \n";
			}
		}
		print "><tr><td> <font size=+2 ";
		if($fontface) {
			print "face=\"$fontface\" ";
		}
		if($bord_text_c) {
			print "color=\"$bord_text_c\" ";
		}
		print ">$Title</font></td></tr><tr><td";
	}
	print " >\n\n";
	print "<tr ";
	foreach $tag (@TR_metas) {
		my $temp = GetElement("${Theme}.${noml_LoginBox}.${noml_TR}.${tag}", %Config);
		if($temp) {
			print " $tag=\"$temp\" \n";
		}
	}
	print " >";
	print "<td ";
	foreach $tag (@TD_metas) {
		my $temp = GetElement("${Theme}.${noml_LoginBox}.${noml_TD}.${tag}", %Config);
		if($temp) {
			print " $tag=\"$temp\" \n";
		}
	}
	print " >\n\n";
	
	print "<font ";
	if($fontface) {
		print "face=\"$fontface\" ";
	}
	if($text_c) {
		print "color=\"$text_c\" ";
	}
	print ">";
	
	print "<br><br><center> This is where the Login Box would be!</center><br><br>\n"; ## HERE!!
	
	print "</font>\n";
	print "</td></tr></table>";
	if($bord_w) {
		print "</td></tr></table>\n";
	}
}

1;
