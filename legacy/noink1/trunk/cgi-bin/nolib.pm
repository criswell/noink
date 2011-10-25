# nolib.pm
# --------
# Contains the various standard subroutines for Noink (its library of sorts)
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

################################
# LoadParams - Loads paramters
# from post data and myURL line
################################
sub LoadParams {
	#Read in myURL query string
	$qury = $ENV{'QUERY_STRING'};

	$qury=~ tr/&/=/;
	%option = split(/=/,$qury);
	
	#Read in post data
	read(STDIN, $post, $ENV{'CONTENT_LENGTH'});
	@name_values = split(/&/, $post);
	%posted = ();
	
	foreach $name_value_pair (@name_values) {
		($post_name, $post_value) = split(/=/, $name_value_pair);
		
		foreach ($post_name, $post_value) {
			#Strip off extra spaces
			s/^\s+//;
			s/\s+$//;
			#Strip off extra newlines
			s/^\n+//;
			s/\n+$//;
			# Convert %32 character codes into the characters
			s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			#Convert pluses into spaces
			tr/+/ /;
		}
		$posted{$post_name} = $post_value;
	}
	
	#Read in Cookie Data
	$cookie_data = $ENV{'HTTP_COOKIE'};
	@cookie_values = split(/;/, $cookie_data);
	%cookie = ();
	
	foreach $cookie_value_pair (@cookie_values) {
		($cookie_name, $cookie_value) = split(/=/, $cookie_value_pair);
		
		foreach ($cookie_name, $cookie_value) {
			#Strip off extra spaces
			s/^\s+//;
			s/\s+$//;
			#Strip off extra newlines
			s/^\n+//;
			s/\n+$//;
		}
		$cookie{$cookie_name} = $cookie_value;
	}
}

#####################
# CopyrightCompute -
# Computes the current
# copyright year list
#####################
sub CopyrightCompute {
	my @years = (0);
	my @outyears = ("");
	$#outyears = -1;
	$#years = -1;
	my $result = "";
	#print "-$admin_root{$root}$copyright_years_file<br>-\n";
	if( open( CFILE, "$admin_root{$root}$copyright_years_file" ) ) {
		@years = <CFILE>;
		close CFILE;
		#print "found it! @years<br>\n";
	} else {
		$years[0] = `$date_options_year`;
		open( CFILE, ">$admin_root{$root}$copyright_years_file" );
		print CFILE "$years[0]\n";
		close CFILE;
	}
	
	#Make sure we have a year line and not a blank line or something else!
	for($i = 0; $i <= $#years; $i++) {
		#Strip off extra spaces
		$years[$i] =~ s/^\s+//;
		$years[$i] =~ s/\s+$//;
		#Strip off extra newlines
		$years[$i] =~ s/^\n+//;
		$years[$i] =~ s/\n+$//;
		# Convert %32 character codes into the characters
		$years[$i] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		if($years[$i] =~ m/[0123456789]/) {
			#We have an actual year line
			push(@outyears, "$years[$i]");
		}
	}
	
	$result = join(", ", @outyears);
	return ($result);
}

##############################
# RunmyURL - Run the myURL request
# returning output to screen
##############################
sub RunmyURL {
	($the_url) = @_;
	$output = `$pre_lynx $lynx $lynx_options "$the_url"`;
	#$output = `TERM="xterm"\n/usr/bin/lynx -source http://192.168.164.174/test/A-docs/HOWTO/noink/test.html`;
	print "$output";
	#print "Did I hit it?<br>";
}

##############################
# ParseHTML - Load and display
# an HTML or plain-text file
# as well as parse for some
# *.noi commands
##############################
sub ParseHTML {
	my ($filename, $deep) = @_;
	#print "$filename<br>\n";
	my $s="";
	my @text=("");
	$#text=-1;
	my $temp="";
	my $forcespace = $no;
	
	if(!$deep) {
		$deep = 1;
	}
		
	#Now, here we have to be careful! This can be recursive, and we do not
	# want to get stuck in an infinite loop!
	if($deep <= $max_recinc_deep) {
		open(HTML_IN, "$filename");
		@text = <HTML_IN>;
		close HTML_IN;
		foreach $s (@text) {
			my $temp = $s;
			if( $temp =~ m/$conf_include/ ) {
				#Strip off extra spaces
				$temp =~ s/^\s+//;
				$temp =~ s/\s+$//;
				#Strip off extra newlines
				$temp =~ s/^\n+//;
				$temp =~ s/\n+$//;
				#Strip off extra tabs
				$temp =~ s/^\t+//;
				$temp =~ s/\t+$//;
				my %inc = split(/$conf_split/,$temp);
				if($inc{$conf_include}) {
					ParseHTML($inc{$conf_include}, $deep+1);
				}
			} elsif( $temp =~ m/$conf_include_rel/ ) {
				#Strip off extra spaces
				$temp =~ s/^\s+//;
				$temp =~ s/\s+$//;
				#Strip off extra newlines
				$temp =~ s/^\n+//;
				$temp =~ s/\n+$//;
				#Strip off extra tabs
				$temp =~ s/^\t+//;
				$temp =~ s/\t+$//;
				my %inc = split(/$conf_split/,$temp);
				if($inc{$conf_include_rel}) {
					ParseHTML("${session_dir}$inc{$conf_include_rel}", $deep+1);
				}

			} elsif( $temp =~ m/$conf_url/ ) {
				#Strip off extra spaces
				$temp =~ s/^\s+//;
				$temp =~ s/\s+$//;
				#Strip off extra newlines
				$temp =~ s/^\n+//;
				$temp =~ s/\n+$//;
				#Strip off extra tabs
				$temp =~ s/^\t+//;
				$temp =~ s/\t+$//;
				my %inc = split(/$conf_split/,$temp);
				if($inc{$conf_url}) {
					RunmyURL($inc{$conf_url});
				}
			} elsif( $temp =~ m/$incdir_fspace/ ) {
				if($forcespace eq $no) {
					$forcespace=$yes;
				} else {
					$forcespace=$no;
				}
			} else {
				#print "-$s-\n$insert_year\n";
				if( $s =~ m/$insert_year/ ) {
					my $tyear = `$date_options_year`;
					$s =~ s/$insert_year/$tyear/;
				}
				if( $s =~ m/$insert_time/ ) {
					my $ttime = `$date_options_time`;
					$s =~ s/$insert_time/$ttime/;
				}
				if( $s =~ m/$insert_full_date/ ) {
					my $tdate = `$date_general`;
					$s =~ s/$insert_full_date/$tdate/;
				}
				if( $s =~ m/$insert_cyear/) {
					my $tcr = CopyrightCompute;
					$s =~ s/$insert_cyear/$tcr/;
				}
				
				if($forcespace eq $no) {
					print "$s\n";
				} else {
					#We will now force spaces!
					my @stemp = split(//, $s);
					foreach $blee (@stemp) {
						if($blee eq " ") {
							print "$fspace";
						} else {
							print "$blee";
						}
					}
				}
			}
		}
	}
}

#######################################################################################################
# BEGIN EXTREMELY UGLY AND POORLY CODED SECTION!

##############################
# DisplaySection - Display the
# sub-section
##############################
sub DisplaySection {
	my ($cur_root_dir) = @_;
	if(defined $cols) {
		$local_cols = $cols;
	} else {
		$local_cols = $conf_default_cols;
	}
	
	my $extra_index = "";
	
	if($option{$option_index_dir} eq $option_index_archive) {
		$extra_index = "&$option_index_dir=$option_index_archive";
	}
	
	my $extra_depth = "";
	
	if($option{$option_dir}) {
		$extra_depth = $option{$option_dir};
	}
	
	print "<table width=\"100%\" cols=$local_cols border=0 cellpadding=0 cellspacing=0 nosave>\n";
	print "<tr><td>";
	$i = 1;
	foreach $loc (@sub) {
		undef $IsViewable;
		undef $CanUpdate;
		#First see if we have the correct permissions to view and/or edit this one
		#Note, even admin will only be able to edit something IF the permissions are correct!
		if(defined $permissions{$loc}) {
			@item_perms = split(/-/, $permissions{$loc});
			
			if ($item_perms[2] =~ /[rR]/) { #other readable, anyone can view it
				$IsViewable = 1;
			} elsif ($item_perms[1] =~ /[rR]/) { #group readable, persons in same group can read it
				if($groups[$user_id] =~ /$group{$loc}/) { #viewer is in same group, can view it
					$IsViewable = 1;
				}
			} elsif ($item_perms[0] =~ /[rR]/) { #owner reabable, should ALWAYS set this!
				if($username[$user_id] eq $owner{$loc}) { #owner is viewing, can view it
					$IsViewable = 1;
				}
			} elsif ($user_id == 0) { #system administrator can always view anything
				$IsViewable = 1;
			}
			
			if ($item_perms[2] =~ /[wW]/) { #other writable, anyone can write to it (CAREFUL HERE!)
				$CanUpdate = 1;
			} elsif ($item_perms[1] =~ /[wW]/) { #group writable, persons in same group can update it
				if($groups[$user_id] =~ /$group{$loc}/) {
					$CanUpdate = 1;
				}
			} elsif ($item_perms[0] =~ /[wW]/) { #owner writable
				if($username[$user_id] eq $owner{$loc}) {
					$CanUpdate = 1;
				}
			} elsif ($user_id == 0) { #sysadmin can always update!
				$CanUpdate = 1;
			}
		} else { #If we have no permissions defined, then I guess the sys admin is telling me ANYONE can view it
			$IsViewable = 1;
		}
		
		if(defined $IsViewable) {
			print "<center>";
			if (!$nolink{$loc}) {
				print "<a href=\"${noink_cgi}?${option_root}=$root&${option_dir}=${extra_depth}$location{$loc}$extra_index\">";
			}
			if ($altlink{$loc}) {
				print "<a href=\"$altlink{$loc}\">";
			}
			if($myURL{$loc}) {
				RunmyURL($myURL{$loc});
			} elsif($image{$loc} & $name{$loc}) {
				print "<img src=\"${cur_root_dir}${extra_depth}$location{$loc}$image{$loc}\" alt=\"$name{$loc}\" border=0>";
			} elsif($image{$loc}) {
				print "<img src=\"${cur_root_dir}${extra_depth}$location{$loc}$image{$loc}\" border=0>";
			} elsif($name{$loc}) {
				print "$name{$loc}";
			}
			if (!$nolink{$loc} | $altlink{$loc}) {
				print "</a>";
			}
			print "<br>\n";
			if(defined $CanUpdate) {
				#print "You could update this<br>\n";
				print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_updateSection}&${option_section}=${loc}$extra_index\">";
				print "$msg_to_update_section{$root}</a>\n<br>";
			}
			if($desc{$loc}) {
				if (!$nolink{$loc}) {
					print "<a href=\"${noink_cgi}?${option_root}=$root&${option_dir}=${extra_depth}$location{$loc}$extra_index\">";
				}
				if ($altlink{$loc}) {
					print "<a href=\"$altlink{$loc}\">";
				}
				print "$desc{$loc}";
				if (!$nolink{$loc} | $altlink{$loc}) {
					print "</a>";
				}
				print "<br>\n";
			}
			if($html_include{$loc}) {
				#print "trying ${session_dir}$html_include{$loc} <br>\n";
				#open(HTML_IN, "${session_dir}$html_include{$loc}");
				#@text = <HTML_IN>;
				#close HTML_IN;
				#print "@text";
				ParseHTML("${session_dir}$html_include{$loc}");
			}
			if($forum{$loc}) {
				print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=${extra_depth}$forum{$loc}$extra_index\">";
				print "$msg_forum{$root}</a><br>\n";
			}
			
			# Following code for feature in 1.2.x
			#if(defined $CanUpdate) {
			#	print "<br><font size=-1 face=courier>";
			#	print "<a href=\"${noink_cgi}?${option_root}=$root&${option_sub}=$loc&${cmd}=${cmd_update}&${option_dir}=${extra_depth}$location{$loc}$extra_index\">$msg_can_update{$root}</a>";
			#	print "<font>";
			#}

			print "</center>";
			$i++;
			if ($i>$local_cols) {
				print "</td></tr><tr><td>\n";
				$i = 1;
			} else {
				print "</td><td>\n";
			}
		}
		print "\n"; #I dont like these things getting all mashed together! ;)
	}
	print "</td></tr></table>";
	print "$section_sep{$root}";
	undef $cols;
	$#sub = -1;
	%image = ();
	%name = ();
	%desc = ();
	%location = ();
	%myURL = ();
	%forum = ();
	%permissions = ();
	%owner = ();
	%group = ();
	%altlink = ();
	%nolink = ();
	%html_include = ();
}

##############################
# ProcessConf - Proccess the
# configuration file, if it
# exists. Also, display the
# necessary sections of the
# conf file.
##############################
sub ProcessConf {
	my ($conf_fname) = @_;
	if($option{$option_index_dir} eq $option_index_archive) {
		$cur_root_dir = $site_archive_root{$root};
	} else {
		$cur_root_dir = $site_root{$root};
	}	
	if(open(CONF, "$conf_fname")) {
		@config_file = <CONF>;
		close CONF;
		undef $loc_noml_startline
		#Check if we are using a new (1.x or on) style configuration file
		for($i = 0; $i <= $#config_file; $i++) {
			if($config_file[$i] =~ m/$noml_start/ ) {
				$loc_noml_startline = $config_file[$i];
				# This is very dangerous, as it requires the version NoML start at the beginning of the file
				# but that's what we want anyway, so oh well
				for($t = 0; $t <- $i; $t++) {
					my $junk=shift(@config_file);
				}
				$i = $#config_file + 1;
			} elsif($config_file[$i] =~ m/$noml_pre_bracket/ ) {
				$i = $#config_file + 1;
			}
		}
		my $loc_version = $version_noml_default;
		if($loc_noml_startline) {
			my @loc_split_startline = split(/$conf_space/,$loc_noml_startline);
			for($i = 0; $i <= $#loc_split_startline; $i++) {
				my @loc_split_element = split(/$conf_split/,$loc_split_startline[$i]);
				# check for the version number
				if($loc_split_element[0] =~ m/$noml_version/ ) {
					$loc_version = $loc_split_element[1];
					$i = $#loc_split_startline + 1;
				}
			}
		}
		
		if($loc_version eq $version_noml_default) {
			#Legacy and crufty junk from 0.x series
			$cur_section = $conf_null;
			undef $cols;
			$display_ran = 0;
			$#sub = -1;
			%image = ();
			%name = ();
			%desc = ();
			%location = ();
			%myURL = ();
			%forum = ();
			%permissions = ();
			%owner = ();
			%group = ();
			%nolink = ();
			%altlink = ();
			%html_include = ();
			foreach $config_line (@config_file) {
				#Strip off extra spaces
				$config_line =~ s/^\s+//;
				$config_line =~ s/\s+$//;
				#Strip off extra newlines
				$config_line =~ s/^\n+//;
				$config_line =~ s/\n+$//;
				#Strip off extra tabs
				$config_line =~ s/^\t+//;
				$config_line =~ s/\t+$//;
				#print "$config_line - cur section= $cur_section <br>\n";
				if ($cur_section eq $conf_null) {
					foreach $s (@conf_sections) {
						if ($config_line eq $s) {
							$cur_section = $s;
						}
					}
				} else {
					if ($config_line eq "${cur_section}${conf_end}" | $config_line eq "${cur_section}${conf_null}") {
						DisplaySection($cur_root_dir);
						$display_ran++;
						$cur_section = $conf_null;
						#print "Back from DisplaySection, cur session=$cur_session <br>\n";
					} else {
						%conf = split(/$conf_split/,$config_line);
						if($conf{$conf_cols}) {
							$cols = $conf{$conf_cols};
						}
						
						if($conf{$conf_sub}) {
							push(@sub, $conf{$conf_sub});
						}
						if($#sub > -1) {
							if($conf{$conf_name}) {
								$name{$sub[$#sub]} = $conf{$conf_name};
							} if($conf{$conf_loc}) {
								$location{$sub[$#sub]} = $conf{$conf_loc};
							} elsif ($conf{$conf_desc}) {
								$desc{$sub[$#sub]} = $conf{$conf_desc};
							} elsif ($conf{$conf_img}) {
								$image{$sub[$#sub]} = $conf{$conf_img};
							} elsif ($conf{$conf_url}) {
								$myURL{$sub[$#sub]} = $conf{$conf_url};
							} elsif ($conf{$conf_forum}) {
								$forum{$sub[$#sub]} = $conf{$conf_forum};
							} elsif ($conf{$conf_owner}) {
								$owner{$sub[$#sub]} = $conf{$conf_owner};
							} elsif ($conf{$conf_group}) {
								$group{$sub[$#sub]} = $conf{$conf_group};
							} elsif ($conf{$conf_permissions}) {
								$permissions{$sub[$#sub]} = $conf{$conf_permissions};
							} elsif ($conf{$conf_link}) {
								$altlink{$sub[$#sub]} = $conf{$conf_link};
							} elsif ($conf{$conf_include}) {
								$html_include{$sub[$#sub]} = $conf{$conf_include};
							} elsif ($config_line eq "$conf_nolink") {
								$nolink{$sub[$#sub]} = $conf_nolink;
							}
							#print "$conf_name - $conf{$conf_name} <br>\n";
						}
					}
				}
			}
		} else {
			#Run the new and improved displayer?
			# Not really certain how I want to go about this!
			my %config_hash = ParseXML_PreLoaded(@config_file);

			no_PaseNOI($loc_version, %config_hash);
		}
		#print "$display_ran";
		if($display_ran == 0) {
			print "$msg_nodata{$root}\n";
		}
	} else {
		print "$msg_nodata{$root}\n";
	}
}

# END EXTREMELY UGLY AND POORLY CODED SECTION
###############################################################################################

##############################
# ParseCookie - Parse the data
# for the cookies and submit
# it to the server
##############################
sub ParseCookie {
	for($i = 0; $i <= $#setcookie_name; $i++) {
		if($setcookie_expires[$i] ne "") {
			print "Set-Cookie: $setcookie_name[$i]=$setcookie_value[$i]; expires=$setcookie_expires[$i]\n";
		} else {
			print "Set-Cookie: $setcookie_name[$i]=$setcookie_value[$i]\n"; # expires=Saturday, 28-Feb-01 23:59:59 GMT\n";
		}
	}
}

##############################
# StartHTML - Begins the CGI
# session with the server and
# starts the HTML page
##############################
sub StartHTML {
	ParseCookie;
	print "Content-type: text/html\n\n";
	print "\n<html>";
	print "\n\t<head>";
	#if(!$qury) {
		print "<meta name=\"resource-type\" content=\"document\">\n";
		print "<meta name=\"classification\" content=\"$classification{$root}\">\n";
		print "<meta name=\"description\" content=\"$description{$root}\">\n";
		print "<meta name=\"keywords\" content=\"$keywords{$root}\">\n";
		print "<meta name=\"rating\" content=\"$rating{$root}\">\n";
		print "<meta name=\"copyright\" content=\"$copyright{$root}\">\n";
		print "<meta name=\"author\" content=\"$author{$root}\">\n";
		print "<meta http-equiv=\"reply-to\" content=\"$replyto{$root}\">\n";
		print "<meta name=\"languag\" content=\"$language{$root}\">\n";
		print "<meta name=\"doc-type\" content=\"Web Page\">\n";
		print "<meta name=\"doc-class\" content=\"Living Document\">\n";
		print "<meta name=\"doc-rights\" content=\"Public\">\n";
	#}
	print "\n\t\t<title>$title{$root}</title>\n";
	print "\n\t</head>\n";
	print "\n\n<body bgcolor=$RearColor{$root} text=$PlainText{$root} vlink=$Vlink{$root} link=$link{$root}";
	if( defined $RearImage{$root} ) {
		print " background=\"$RearImage{$root}\" ";
	}
	print ">";
	BannerDisplay;
	#Do the topbar stuff
	print "\n<center><table width=$topbar_w{$root} bgcolor=$BGColor{$root} border=$topbar_border{$root} cellpadding=$topbar_padding{$root} cellspacing=$topbar_spacing{$root} ";
	if( defined $BGImage{$root} ) {
		print " background=\"$BGImages{$root}\" ";
	}
	print ">";
	print "\n<tr valign=center>";
	print "\n<td rowspan=2 align=center width=$logo_width{$root}>";
	ParseHTML("$topbar_file{$root}");
	print "<br>";
	print "</td></tr></table></center>\n\n\n";
}

###################################
# LeftBar - Displays the left bar
# data and included files
###################################
sub LeftBar {
	print " <table width=$page_width{$root} bgcolor=$BGColor{$root} border=$page_border{$root} cellpadding=$page_padding{$root} cellspacing=$page_spacing{$root}";
	if( defined $BGImage{$root} ) {
		print " background=\"$BGImage{$root}\" ";
	}
	print ">";
	print "  <tr valign=top>";
	print "   <td rowspan=2 align=left width=$leftbar_w{$root}>";
	#Load the left bar headless html file
	ParseHTML("$leftbar_file{$root}");
	print "   </td>";
	print "   <td align=left colspan=6 width=$main_width{$root} valign=top>";
}

##############################
# MainPage - Displays the main
# page if data exists
##############################
sub MainPage {
	print "<!-- Main Section -->\n\n";
	#print " $hidden_username = $cookie{$hidden_username}<br>";
	#print " $hidden_password = $cookie{$hidden_password}<br>";
	#print " $hidden_password_key = $cookie{$hidden_password_key}<br>";
	#print @enc_key;
	#print "$shell_shocked<br>Now decrypt<br>";
	#print "<br>==$poopy_land!$print_me_dammit-<br>!$promised_land-";
	ProcessConf("${session_dir}$index_file");
}

################################
# RightBar - Displays the right
# bar, including any extra files
################################
sub RightBar {
	ParseHTML("$rightbar_file{$root}");
}

##########################
# CopyrightEnd - The last
# thing on the screen.
# Loads the small copyright
# HTML file
##########################
sub CopyrightEnd {
	print "<a href=\"${noink_cgi}?${option_root}=$root&$cmd=$cmd_copylong\">";
	ParseHTML("$copyrite_small{$root}");
	print "</a><br>\n";
}

################################
# EndHTML - End the HTML page
################################
sub EndHTML {
	print " </td></tr></table><center>\n";
	CopyrightEnd;
	print "</center></body></html>";
}

##########################
# CopyrightMain - the main
# copyright parser
##########################
sub CopyrightMain {
	ParseHTML("$copyrite_large{$root}");
}

1;