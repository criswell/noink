#!/usr/bin/perl -w
#
# noink.cgi
# ----------
# Noink web-content thingy
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

#use NoinkLib;

#use NoinkML;

use nobanner;

use nolib;

use novariables;

use noconf;

use noarchive;

use noadmin;

use noml;

use noforum;

#Start ourselves a new output interface
$noCGI = new CGI;

# First, let's get any parameters (posted or options) we've been passed
LoadParams;

#Next, ensure that the cookies to be set are not yet declared
#(NOTE: I am assuming that I'll never need any /really/ complicated cookies)
$#setcookie_name = -1;
$#setcookie_value = -1;
$#setcookie_expires = -1;

#Process URL options
if ($option{$option_root}) { # determine which root site to use
	$root = $option{$option_root};
	#$blimy1 = "-$root-";
	$i = 0;
	foreach $site (@root_sites) {
		#$blimy1 = "$blimy1 <br>\n -$site- w/ $i";
		if($site !~ /$root/) {
			$i++;
		}
	}
	#$blimy1 = "$blimy1 <br>\n<br>\n $i was found, with $#root_sites possuble...<br>\n";
	if($i == $#root_sites - 1) { # If not a valid site, use default site
		$root = $root_sites[0];
	}
} else { # Use default site
	$root = $root_sites[0];
	#$blimy1 = "BLIMY we never even got in there!<br>\n";
}

#Next load and parse the password file
LoadPasswdFile;

#Check administration level
#Start out logged in only as guest
$user_id = $guest_user;
#Check if Logged in
UserLogin;

if($option{$option_dir}) {
	if($option{$option_index_dir} eq $option_index_archive) {
		$d_root = $archive_root{$root};
	} else {
		$d_root = $data_root{$root};
	}
	$session_dir = "$d_root${option{$option_dir}}";
	$present_dir_command = "$option_dir=$option{$option_dir}";
} else { # Use default site's dir
	if($option{$option_index_dir} eq $option_index_archive) {
		$d_root = $archive_root{$root};
	} else {
		$d_root = $data_root{$root};
	}
	$session_dir = $d_root;
	$present_dir_command = "";
}

if ($option{$cmd} eq $cmd_admin) {
	StartHTML;
	LeftBar;
	AdminMain;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_usermanage) {
	StartHTML;
	LeftBar;
	UserManage; #user, menage a troi'?
	EndHTML;
} elsif ($option{$cmd} eq $cmd_deleteuser) {
	StartHTML;
	LeftBar;
	DeleteUserDialog;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_newuser) {
	StartHTML;
	LeftBar;
	NewUserDialog;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_remind) {
	StartHTML;
	LeftBar;
	PassRemind;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_userconfig) {
	StartHTML;
	LeftBar;
	UserUpdate;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_forum) {
	StartHTML;
	LeftBar;
	ForumMain;
	LoginBox;
	AdminTaskbar;
	RightBar;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_archive) {
	StartHTML;
	LeftBar;
	ArchiveMain;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_copylong) {
	StartHTML;
	LeftBar;
	CopyrightMain;
	LoginBox;
	AdminTaskbar;
	RightBar;
	EndHTML;
} elsif ($option{$cmd} eq $cmd_pre) {
	StartHTML;
	LeftBar;
} elsif ($option{$cmd} eq $cmd_post) {
	#LoginBox;
	#AdminTaskbar;
	#RightBar;
	EndHTML;
} else {
	StartHTML;
	LeftBar;
	ArchiveList;
	MainPage;
	LoginBox;
	AdminTaskbar;
	RightBar;
	EndHTML;
}