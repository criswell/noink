#!/usr/bin/perl -w
#
# nonews.cgi
# ----------
# NoNews (is good news)
# - Very simple and stupid hack to integrate some
# very rudimentary news/article/forum/journal type
# dealy to Noink. May not integrate.... but oh well
# bite me bum. Truthfully, I just couldn't think of
# a good name for this, so just went with the whole
# Noink thing I've been doing!
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

use CGI;

use nonewsconf;

use nonewsvars;

use noadmin;

use noml;

use nobanner;

use nonewslib;

#Start ourselves a new output interface
$co = new CGI;

# see if we have a preferred site-theme
undef $Theme;
if($co->cookie($cookie_theme)) {
	$Theme = $co->cookie($cookie_theme);
} else {
	$Theme = $default_str;
}

# Load the configuration & password file
if($co->param($param_conf_prefix)) {
	my $prefix = $co->param($param_conf_prefix);
	#Prefixed config file
	%Config = ParseXML("${location_configs}${prefix}_nonews.conf");
	%Passwd = ParseXML("${location_admin}${prefix}_nonews.pass");
} else {
	%Config = ParseXML("${location_configs}nonews.conf");
	%Passwd = ParseXML("${location_admin}nonews.pass");
}

$Data_Dir = GetElement($noml_data, %Config);

# Start the document
StartHTML;

if($co->param($param_cmd) eq $param_read) {
	#Read a message
	my $me_inside = $no;

	@Layout = GetElements("${noml_layout}.${noml_HeadLines}", %Config);
	foreach $lay_line (@Layout) {
		my @lay_arr = split(/;/, $lay_line);
		if($#lay_arr == -1) {
			$lay_arr[0] = $lay_line;
		}

	
		if($me_inside ne $yes) {
			print "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n";
			$me_inside = $yes;
		}
	
		# Divide up the work
		if($lay_arr[0] eq $noml_BreakingNews) {
			BreakingNews($lay_arr[1]);
		} elsif ( $lay_arr[0] eq $noml_HeadLines) {
			Read_HeadLine;
		} elsif ($lay_arr[0] eq $noml_LoginBox) {
			Admin_LoginBox("-", "-", "-", "Login Box", "-", "-", "-", "-", "-", "-", "-");
		} elsif ($lay_arr[0] eq $noml_end) {
			print "</table><br>\n\n";
			$me_inside = $no;
		} elsif ($lay_line eq $noml_end) {
			print "</table><br>\n\n";
			$me_inside = $no;
		}
	}

	# Clear up any errant table stuffies
	if($me_inside eq $yes) {
		print "</table>\n";
	}
} elsif ($co->param($param_cmd) eq $param_more) {
	#Continue reading from where we were
	my $me_inside = $no;

	@Layout = GetElements("${noml_layout}.${noml_more}", %Config);
	foreach $lay_line (@Layout) {
		my @lay_arr = split(/;/, $lay_line);
		if($#lay_arr == -1) {
			$lay_arr[0] = $lay_line;
		}
	
		if($me_inside ne $yes) {
			print "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n";
			$me_inside = $yes;
		}
	
		# Divide up the work
		if($lay_arr[0] eq $noml_BreakingNews) {
			BreakingNews($lay_arr[1]);
		} elsif ( ($lay_arr[0] eq $noml_HeadLines) | ($lay_line eq $noml_HeadLines)) {
			#Read_HeadLine;
			my $lower_width = GetElement("${Theme}.${noml_HeadLines}.${noml_body}.${noml_width}", %Config);
			#print "trying ${Theme}.${noml_HeadLines}.${noml_body}.${noml_width} for $lower_width\n<br>";
			HeadLines($co->param($param_dir), $lay_arr[2], $lay_arr[3], $lower_width);  #1 - work-dir, #2 - num lines head, #3 - num lines body
		} elsif ($lay_arr[0] eq $noml_end) {
			print "</table><br>\n\n";
			$me_inside = $no;
		} elsif ($lay_arr[0] eq $noml_LoginBox) {
			Admin_LoginBox("-", "-", "-", "Login Box", "-", "-", "-", "-", "-", "-", "-");
		} elsif ($lay_line eq $noml_end) {
			print "</table><br>\n\n";
			$me_inside = $no;
		}
	}

	# Clear up any errant table stuffies
	if($me_inside eq $yes) {
		print "</table>\n";
	}
} else {
	#Default Display
	my $me_inside = $no;

	@Layout = GetElements($noml_layout, %Config);
	foreach $lay_line (@Layout) {
		my @lay_arr = split(/;/, $lay_line);
		#print "cur line $lay_line\n<br>";
		if($#lay_arr == -1) {
			$lay_arr[0] = $lay_line;
		}
	
		if($me_inside ne $yes) {
			print "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n";
			$me_inside = $yes;
		}
	
		# Divide up the work
		if($lay_arr[0] eq $noml_BreakingNews) {
			BreakingNews($lay_arr[1]);
		} elsif ($lay_arr[0] eq $noml_HeadLines) {
			my $lower_width = GetElement("${Theme}.${noml_HeadLines}.${noml_body}.${noml_width}", %Config);
			#print "trying ${Theme}.${noml_HeadLines}.${noml_body}.${noml_width} for $lower_width\n<br>";
			HeadLines($lay_arr[1], $lay_arr[2], $lay_arr[3], $lower_width);  #1 - work-dir, #2 - num lines head, #3 - num lines body
		} elsif ($lay_arr[0] eq $noml_end) {
			print "</table><br>\n\n";
			$me_inside = $no;
		} elsif ( ($lay_arr[0] eq $noml_LoginBox) | ($lay_line eq $noml_LoginBox) ) {
			print "</td><td>";
			Admin_LoginBox("-", "-", "-", "Login Box", "-", "-", "-", "-", "-", "-", "-");
		} elsif ($lay_line eq $noml_end) {
			print "</table><br>\n\n";
			$me_inside = $no;
		}
	}

	# Clear up any errant table stuffies
	if($me_inside eq $yes) {
		print "</table>\n";
	}
}

EndHTML;

