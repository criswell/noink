# noadmin.pm
# noink admin app
# ---------------
# Contains all the administration subroutines for Noink.
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

#########################################################################
# LEGACY FUNCTIONS : The following functions are legacy ones from early
# Noink work. They are intended to be phased out over time and version
# iterations.

###########################
# LoadPasswdFile - Load and
# parse the password file
# if doesn't exist, then
# make new one
###########################
sub LoadPasswdFile {
	$#username = -1;
	$#password = -1;
	$#groups = -1;
	if(open(PASSWD, "${admin_root{$root}}$passwd_file")) {
		#hooray, we have a password file!
		@pass_contents = <PASSWD>;
		foreach $pass_line (@pass_contents) {
			@pass_array = split(/:/, $pass_line);
			$username[int($pass_array[0])] = $pass_array[1];
			$password[int($pass_array[0])] = $pass_array[2];
			$groups[int($pass_array[0])] = $pass_array[3];
		}		
	} else {
		#aww... no password file... well, let's make one!
		mkdir "${admin_root{$root}}$accounts", 0700;
		open(PASSWD, ">${admin_root{$root}}$passwd_file");
		#stick the standard password junk in there (all that is really needed)
		print PASSWD "0:admin:${default_admin_passwd{$root}}:admin\n";
		print PASSWD "$guest_user:other:none:other\n";
		@username = ("admin", "other");
		@password = ("${default_admin_passwd{$root}}", "none");
		@groups = ("admin", "other");
	}
	close PASSWD;
	chmod 0700, "${admin_root{$root}}$passwd_file"; #we dont want peoples goings around and viewink our password file!
}

###########################
# SavePasswdFile - Save and
# parse the password file
# if doesn't exist, then
# make new one
###########################
sub SavePasswdFile {
	#strip extra junk from these fields
	foreach(@username, @password, @groups) {
		#Strip off extra spaces
		s/^\s+//;
		s/\s+$//;
		#Strip off extra newlines
		s/^\n+//;
		s/\n+$//;
		#Ensure we have , symbols!
		#tr/@2C/,/s;
	}
	if(open(PASSWD, ">${admin_root{$root}}$passwd_file")) {
		#hooray, we have a password file!
		for($spf = 0; $spf <= $#username; $spf++) {
			print PASSWD "$spf:$username[$spf]:$password[$spf]:$groups[$spf]\n";
		}
	} else {
		#aww... no password file... well, let's make one!
		mkdir "${admin_root{$root}}$accounts", 0700;
		open(PASSWD, ">${admin_root{$root}}$passwd_file");
		#stick the standard password junk in there (all that is really needed)
		for($spf = 0; $spf <= $#username; $spf++) {
			print PASSWD "$spf:$username[$spf]:$password[$spf]:$groups[$spf]\n";
		}
	}
	close PASSWD;
	chmod 0700, "${admin_root{$root}}$passwd_file"; #we dont want peoples goings around and viewink our password file!
}

##############################
# AddUser - Given parameters
# this will add the new user
##############################
# WARNING: New user parameters
# must have already been
# validated!!!!!!!!!!!!!!!!!!!
##############################

sub AddUser {
	($add_name, $add_password, $add_group) = @_;
	#check on highest user id
	$new_id = $#username + 1; #alright, this will leave gaps if you go and add users with strange ids... but that's your fault if it happens, because you really ought not to do that
	
	open(PASSWD, ">>${admin_root{$root}}$passwd_file");
	print PASSWD "$new_id:$add_name:$add_password:$add_group\n";
	close PASSWD;
	chmod 0700, "${admin_root{$root}}$passwd_file"; #we dont want peoples goings around and viewink our password file!
	return $new_id;
}

################################
# AddExtras - Add all the extra
# junk we may get in other files
################################

sub AddExtras {
	@params = @_;
	$new_id = $params[0];
	open(EXTRAS, ">${admin_root{$root}}${accounts}${extra_blank}.$new_id");
	for($i = 1; $i <= $extras_used{$root}; $i++) {
		$extra_guy = $posted{"${extra_blank}${i}"};
		print EXTRAS "$extra_guy\n";
	}
	close EXTRAS;
}

##############################
# GetExtras - Obtain an extra
# value from the extra file
# if not there, return undef
##############################
sub GetExtras {
	@params = @_;
	$lookup = $params[0] - 1;
	$new_id = $params[1];
	undef $return_guy;
	if(open(EXTRAS, "${admin_root{$root}}${accounts}${extra_blank}.$new_id")) {
		@extra_cont = <EXTRAS>;
		close EXTRAS;
		$return_guy = $extra_cont[$lookup];
	}
	$return_guy =~ s/^\s+//;
	$return_guy =~ s/\s+$//;
	$return_guy =~ s/^\n+//;
	$return_guy =~ s/\n+$//;
	$return_guy =~ tr/%40/@/s;
	return $return_guy;
}

##############################
# NewUserDialog - The dialog
# for adding new users
##############################
sub NewUserDialog {
	#print "$groups[$user_id]<br>";
	if($users_add_own_accounts{$root} eq $no & $groups[$user_id] !~ /admin/) {
		print "$msg_add_user_sorry{$root}<br>\n";
		#only do anything if we can add new-users
	} elsif ($user_id != $guest_user & $groups[$user_id] !~ /admin/) {
		print "$msg_sorry_adminonly{$root}<br><br>\n\n";
	} else {
		#first, check to see if we already did all this
		undef $name_taken;
		undef $pass_match;
		undef $pass_small;
		undef $new_name;
		if($posted{$form_update_username}) {
			#first check if we have any conflicts with this name
			foreach $s (@username) {
				if($posted{$form_update_username} eq $s) {
					$name_taken = $yes;
				}
			}
			if($posted{$form_update_password} ne $posted{$form_password_verify}) {
				$pass_match = $no;
			} else {
				$pass_match = $yes;
			}
			$temp = $posted{$form_update_password};
			#$count = ($temp =~ tr/*/*/);
			$count = ($temp =~ s/./*/g); # { $count++ }
			if($count < $min_password_size{$root}) {
				$pass_small = $yes;
			}
			$new_name = $yes;
		}
		
		if($new_name eq $yes & $name_taken ne $yes & $pass_match ne $no & $pass_small ne $yes) {
			if($groups[$user_id] !~ /admin/) {
				$new_id = AddUser($posted{$form_update_username}, $posted{$form_update_password}, $default_group{$root});
			} else {
				$new_id = AddUser($posted{$form_update_username}, $posted{$form_update_password}, $posted{$form_groups});
			}
			if($extras_used{$root} > 0) {
				AddExtras($new_id);
			}
			if($groups[$user_id] !~ /admin/) {
				print "<font size=+1 face=arial,helvetica><b>$msg_newuser_success{$root}</b></font><br>";
			} else {
				print "<font size=+1 face=arial,helvetica><b>$msg_account_added{$root}</b></font><br>";
				print "<br><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage\">$msg_useredit_back{$root}</a><br>\n";
			}
		} else {
			print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
			print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}";
			if($groups[$user_id] !~ /admin/) {
				print "$msg_newuserdialog{$root}";
			} else {
				print "$msg_account_add_dialog{$root}";
			}
			print "</b></font></td><br>\n";
			if($pass_match eq $no | $name_taken eq $yes | $pass_small eq $yes) {
				print "<td align=left valign=center bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_newuserdialog_error{$root}</b></font>";
			}
			print "</td></tr><td align=left>";
			print "<br><form method=\"post\" action=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_newuser\" enctype=\"application/x-www-form-urlencoded\">\n";
			if($groups[$user_id] !~ /admin/) {
				print "$msg_newuser_instruct{$root}<br><br>\n\n";
			} else {
				print "$msg_account_add_instruct{$root}<br><br>\n\n";
			}
			print "${blank_space}${blank_space}$msg_newuser_username{$root}<br>\n";
			print "${blank_space}<input type=\"text\" name=\"$form_update_username\" value=\"$posted{$form_update_username}\"><br><br>\n";
			print "${blank_space}${blank_space}$msg_newuser_password1{$root}<br>\n";
			print "${blank_space}<input type=\"password\" name=\"$form_update_password\" value=\"\"><br><br>\n";
			print "${blank_space}${blank_space}$msg_newuser_password2{$root}<br>\n";
			print "${blank_space}<input type=\"password\" name=\"$form_password_verify\" value=\"\"><br><br>\n";
			if($groups[$user_id] =~ /admin/) {
				print "${blank_space}${blank_space}$msg_account_add_groups{$root}<br>\n";
				print "${blank_space}<input type=\"test\" name=\"$form_groups\" value=\"$default_group{$root}\"><br><br>\n";
			}
			for ($i = 1; $i <= $extras_used{$root}; $i++) {
				print "${blank_space}${blank_space}$msg_extra{$root}[$i]<br>\n";
				print "${blank_space}<input type=\"text\" name=\"${extra_blank}${i}\" value=\"\"><br><br>\n";
			}
			if($extras_used{$root} > 0) {
				print "$privacy_policy{$root}";
			}
			print "<br><input type=SUBMIT value=\"Submit\"> <input type=RESET value=\"Reset\"></form>";
			print "</td><td align=left valign=top>";
			if($pass_match eq $no | $name_taken eq $yes | $pass_small eq $yes) {
				print "$msg_newuser_errors_instruct{$root}<br><br><ul>\n\n";
				if($name_taken eq $yes) {
					print "<li>$msg_newuser_nametaken{$root}</li><br>\n";
				}
				if($pass_match eq $no) {
					print "<li>$msg_newuser_passdontmatch{$root}</li><br>\n";
				}
				if($pass_small eq $yes) {
					print "<li>$msg_newuser_passtoosmall{$root}</li><br>\n";
				}
				print "</ul>";
			}
			print "</td></tr></table>";
		}
	}
	if($groups[$user_id] =~ /admin/) {
		print "<br><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage\">$msg_useredit_back{$root}</a><br>\n";
	}
}

###############################
# AdminTaskBar - Give an
# administrative task-bar
# appropriate to the logged in
# user's level
###############################
sub AdminTaskbar {
	if($user_id == $guest_user) {
		#There's no need to continue... user must be logged in
		print "<!-- guest user -->\n";
	} else {
		print "<table width=\"100%\" bgcolor=\"$AdminBGColor{$root}\" border=5 cellpadding=0 callspacing=0><tr><td>\n";
		print "<font size=+1 face=arial,helvetica><b>$msg_adminbar{$root}</b></font><br><br>\n";
		print "<a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_userconfig\">$msg_userconfig{$root}</a><br><br>";
		if($groups[$user_id] =~ /admin/) {
			print "<a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_admin\">$msg_adminconfig{$root}</a><br><br>";
			if($can_archive{$root} eq $yes) {
				print "<a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_archive\">$msg_archive_site{$root}</a><br><br>";
			}
		}
		print "</table>\n";
	}
}

#################################
# AdminMain - Main administration
# page for the admin user
#################################
sub AdminMain {
	#It's always best to verify that we're actually admin!
	if($groups[$user_id] !~ /admin/) {
		print "$msg_sorry_adminonly{$root}<br>";
	} else {
		print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
		print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_adminmain_dialog{$root}</b></font></td><br>\n";
		print "</td></tr><td align=left>";
		print "$msg_adminmain_instruct{$root}<br><br>\n";
		print "<ul><li><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage\">$msg_adminmain_usermanage{$root}</a></li><br>\n";
		print "<li><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_lockadmin\">$msg_adminmain_lockouts{$root}</a></li><br>\n";
		print "</ul></td></tr></table>";
	}
}

###############################
# DeleteUserDialog - Dialog for
# deleting a user from the
# database. (admin only!)
###############################
sub DeleteUserDialog {
	#It's always best to verify that we're actually admin!
	if($groups[$user_id] !~ /admin/) {
		print "$msg_sorry_adminonly{$root}<br>";
	} else {
		if($option{$option_uid}) {
			$uid = $option{$option_uid};
			if($uid == $guest_user | $uid == 0) {
				print "$msg_sorry_cannotmodify{$root}<br>";
			} elsif ($uid == $posted{$form_hidden_id}) {
				if($uid > $#username) {
					#Wait a minute, that's not right!
					print "$msg_deletuser_error{$root}<br><br>\n\n";
				} else {
					#Woah, this guy's serious! Guess we need to delete the user!
					#now, must get rid of extras file
					unlink ("${admin_root{$root}}${accounts}${extra_blank}.$uid");
					#First, get rid of them in the password file.
					$#new_username = -1;
					$#new_password = -1;
					$#new_groups = -1;
					for($i = 0; $i < $uid; $i++) {
						$new_username[$i] = $username[$i];
						$new_password[$i] = $password[$i];
						$new_groups[$i] = $groups[$i];
					}
					if($uid < $#username) {
						for($i = $uid+1 ; $i <= $#username; $i++) {
							$new_username[$i-1] = $username[$i];
							$new_password[$i-1] = $password[$i];
							$new_groups[$i-1] = $groups[$i];
							$j = $i-1;
							rename "${admin_root{$root}}${accounts}${extra_blank}.$i", "${admin_root{$root}}${accounts}${extra_blank}.$j";
						}
					}
					#Replace dem bastiches!
					$#username = -1;
					$#password = -1;
					$#groups = -1;
					@username = @new_username;
					@password = @new_password;
					@groups = @new_groups;
					SavePasswdFile;
					LoadPasswdFile;
					
					print "$msg_deleteuser_success{$root}<br><br>\n\n";
				}
			} else {
				print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
				print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_deleteuser_dialog{$root}</b></font></td><br>\n";
				print "</td></tr><td align=left>";
				print "$msg_deleteuser_instruct{$root}<br><br>\n";
				print "<table width=\"90%\" cols=2 border=0 cellpadding=\"10\" cellspacing=\"10%\" nosave>";
				print "<tr><td align=left valign=top bgcolor=$AdminBGLight{$root}><ul>\n";
				print "<br><form method=\"post\" action=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_deleteuser&$option_uid=$uid\" enctype=\"application/x-www-form-urlencoded\">\n";
				print "${blank_space}${blank_space}<b>#$uid : $msg_useredit_username{$root}</b><br>\n";
				print "${blank_space}$username[$uid]<br><br>\n";
				print "${blank_space}${blank_space}<b>$msg_useredit_groups{$root}</b><br>\n";
				print "${blank_space}$groups[$uid]<br><br>\n";
				print "<input type=\"hidden\" name=\"$form_hidden_id\" value=\"$uid\">";
				for ($i = 1; $i <= $extras_used{$root}; $i++) {
					print "${blank_space}${blank_space}<b>$msg_extra{$root}[$i]</b><br>\n";
					$extra_cont = GetExtras($i, $uid);
					print "${blank_space}$extra_cont<br><br>\n";
				}
				print "<br><input type=SUBMIT value=\"DELETE\"></form>";
				print "</td><td align=left valign=top>";
				print "</td></tr></table></td></tr></table>";
			}
			print "<br><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage\">$msg_useredit_back{$root}</a><br>\n";		
		}
	}
}

###############################
# UserManage - Manage the user
# database and password file
# (for administrator only)
###############################
sub UserManage {
	#verify we have someone with admin access
	if($groups[$user_id] !~ /admin/) {
		print "$msg_sorry_adminonly{$root}<br>";
	} else {
		if($option{$option_uid}) {
			$uid = $option{$option_uid};
			if($uid == $guest_user | ($uid == 0 & $user_id != 0)) {
				print "$msg_sorry_cannotmodify{$root}<br>";
			} else {
				#next, see if we already did all this
				undef $pass_match;
				undef $pass_small;
				undef $name_new;
				undef $pass_changed;
				undef $extras_changed;
				if($posted{$form_update_password}) {
					if($posted{$form_update_password} ne $posted{$form_password_verify}) {
						$pass_match = $no;
					} else {
						$pass_match = $yes;
					}
					$temp = $posted{$form_update_password};
					$count = ($temp =~ s/./*/g);
					if($count < $min_password_size{$root}) {
						$pass_small = $yes;
					}
					if($posted{$form_update_password} ne $password[$user_id]) {
						$pass_changed = $yes;
					} else {
						$pass_changed = $no;
					}
				}
				
				if($posted{$form_update_username}) {
					if($posted{$form_update_username} ne $username[$uid]) {
						#check if there is a conflict
						foreach $n (@username) {
							if($n eq $posted{$form_update_username}) {
								$name_new = $no;
								$user_conflict = $n
							}
						}
					} else {
						$name_new = $yes;
					}
				}

				if($posted{"${extra_blank}1"}) {
					if($extras_used{$root} > 0) {
						for($i = 1; $i <= $extras_used{$root}; $i++) {
						
							if(GetExtras($i, $user_id) ne $posted{"${extra_blank}${i}"}) {
								$extras_changed = $yes;
							}
						}
						if($extras_changed eq $yes) {
							AddExtras($uid);
						}
					}
				}
				if($name_new eq $yes | ($pass_changed eq $yes & $pass_match ne $no & $pass_small ne $yes)) {
					UpdateAccount($uid, $posted{$form_update_username}, $posted{$form_update_password}, $posted{$form_update_groups});
					LoadPasswdFile;
				}			
				print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
				print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_usermanage_dialog{$root}</b></font></td><br>\n";
				print "</td></tr><td align=left>";
				print "$msg_useredit_instruct{$root}<br><br>\n";
				print "<table width=\"90%\" cols=2 border=0 cellpadding=\"10\" cellspacing=\"10%\" nosave>";
				print "<tr><td align=left valign=top bgcolor=$AdminBGLight{$root}><ul>\n";
				print "<br><form method=\"post\" action=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage&$option_uid=$uid\" enctype=\"application/x-www-form-urlencoded\">\n";
				print "${blank_space}${blank_space}<b>#$uid : $msg_useredit_username{$root}</b><br>\n";
				print "${blank_space}<input type=\"text\" name=\"$form_update_username\" value=\"$username[$uid]\"><br><br>\n";
				print "${blank_space}${blank_space}$msg_useredit_password1{$root}<br>\n";
				print "${blank_space}<input type=\"password\" name=\"$form_update_password\" value=\"$password[$uid]\"><br><br>\n";
				print "${blank_space}${blank_space}$msg_useredit_password2{$root}<br>\n";
				print "${blank_space}<input type=\"password\" name=\"$form_password_verify\" value=\"$password[$uid]\"><br><br>\n";
				print "${blank_space}${blank_space}$msg_useredit_groups{$root}<br>\n";
				print "${blank_space}<input type=\"text\" name=\"$form_update_groups\" value=\"$groups[$uid]\"><br><br>\n";
				for ($i = 1; $i <= $extras_used{$root}; $i++) {
					print "${blank_space}${blank_space}$msg_extra{$root}[$i]<br>\n";
					$extra_cont = GetExtras($i, $uid);
					print "${blank_space}<input type=\"text\" name=\"${extra_blank}${i}\" value=\"$extra_cont\"><br><br>\n";
				}
				if($extras_used{$root} > 0) {
					print "$privacy_policy{$root}";
				}
				print "<br><input type=SUBMIT value=\"Submit\"> <input type=RESET value=\"Reset\"></form>";
				print "</td><td align=left valign=top>";
				if($extras_changed eq $yes | $name_new eq $yes | ($pass_changed eq $yes & $pass_match ne $no & $pass_small ne $yes)) {
					print "$msg_useredit_success{$root}<br>\n";
				}
				if($name_new eq $no | $pass_match eq $no | $pass_small eq $yes) {
					print "$msg_useredit_errors{$root}<br>\n";
					print "<ul>";
					if($name_new eq $no) {
						print "<li>$msg_useredit_nameconflict{$root} - $user_conflict</li><br>\n";
					}
					if($pass_match eq $no) {
						print "<li>$msg_useredit_passdontmatch{$root}</li><br>\n";
					}
					if($pass_small eq $yes) {
						print "<li>$msg_useredit_passtoosmall{$root}</li><br>\n";
					}
					print "</ul>";
				}
				print "</td></tr></table></td></tr></table>";
			}
			print "<br><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage\">$msg_useredit_back{$root}</a><br>\n";
		} else 	{
			print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
			print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_usermanage_dialog{$root}</b></font></td><br>\n";
			print "</td></tr><td align=left>";
			print "$msg_usermanage_instruct{$root}<br><br>\n";
			print "<table width=\"90%\" cols=3 border=0 cellpadding=\"10\" cellspacing=\"10%\" nosave>";
			print "<tr><td align=center bgcolor=$AdminBGLight{$root}><ul>\n";
			$num_per_col = $#username / 3; #/
			$num_count = 0;
			for($i=0 ; $i <= $#username; $i++) {
				print "<li><a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_usermanage&$option_uid=$i\">$i: $username[$i]</a> - <a href=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_deleteuser&$option_uid=$i\">$msg_delete_user{$root}</a></li><br>\n";
				$num_count++;
				if($num_count > $num_per_col) {
					$num_count = 0;
					print "\n<ul>\n</td><td align=center bgcolor=$AdminBGLight{$root}><ul>\n";
				}
			}
			print "</ul></td></tr></table></td></tr></table>";
			NewUserDialog;
		}
	}
}

###############################
# DecryptPassword - Take
# encrypted password and number
# of key used, and return the
# decrypted password
###############################
sub DecryptPassword {
	#we just assume that all these hashes have values right here
	my $keynum = $cookie{$hidden_password_key};
	my $encrypted_password = $cookie{$hidden_password};
	my $test_username = $cookie{$hidden_username};
	
	my $decrypted_password = "";
	
	for($i = 0; $i <= $#username; $i++) {
		if($username[$i] eq $test_username) {
			$id = $i;
		}
	}
	
	my $letter_org = $letter_rep = ' ';
	
	if(open(KEYFILE, "${admin_root{$root}}$accounts$id${key_file}.$keynum")) {

		@enc_key = <KEYFILE>;
		close KEYFILE;
		@temp_pass = split(//, $encrypted_password);
		for($boo = 0; $boo <= $#temp_pass; $boo++) {
			CONTINUE_GUY: foreach $s (@enc_key) {
				#Strip off extra spaces
				$s =~ s/^\s+//;
				$s =~ s/\s+$//;
				#Strip off extra newlines
				$s =~ s/^\n+//;
				$s =~ s/\n+$//;
				#Split
				($letter_org, $letter_rep) = split(/,/, $s);
			
				#replace appropriate chars
				#I would /really/ be open to suggestions on how to do this more efficiently
			
				if($temp_pass[$boo] eq $letter_org) {
					$temp_pass[$boo] = $letter_rep;
					last CONTINUE_GUY;
				}
			}
			
			#keeping the folloing code in... this is what I would like to do, but it doesnt work
			#any suggestions????
			#$encrypted_password =~ tr/$letter_org/$letter_rep/;
		}
		$decrypted_password = join("", @temp_pass);
	}
	return $decrypted_password;
}

################################
# AddCookie - Takes cookie
# elements and adds a new cookie
# for them
################################

sub AddCookie {
	($add_name, $add_value, $add_exp) = @_;
	push(@setcookie_name, $add_name);
	push(@setcookie_value, $add_value);
	push(@setcookie_expires, $add_exp);
}

###############################
# SetExpiry - Takes number of
# days to set for an expiration
# date
###############################
sub SetExpiry {
	#The following is a quick and dirty solution.... it sucks, but not that important to me...
	#...so, if you want better, feel free to change it and submit those changes to me...
	($days) = @_;
	$wkdy = `$date_options_wkdy`;
	$dnum = `$date_options_daynum`;
	$mon = `$date_options_month`;
	$year = `$date_options_year`;
	$time = `$date_options_time`;
	
	$dnum += $days;
	if($dnum >= 29) {
		#Alright, this is lazy of me.... I know I should have cases for the various months with different numbers of days in them... bite me
		$dnum = 1;
		$temp_mon = -1;
		for($i = 0; $i <= $#month; $i++) {
			if($month[$i] eq $mon) {
				$temp_mon = $i;
			}
		}
		if($temp_mon >= 0) {
			if($temp_mon <= $#month) {
				$mon = $month[$temp_mon];
			} else {
				$mon = $month[0];
				$year++;
			}
		}
	}
	
	#the following also breaks down on month/year boundries as applied above... but oh well
	$temp_wkdy = -1;
	for($i = 0; $i <= $#day; $i++) {
		if($day[$i] eq $wkdy) {
			$temp_wkdy = $i;
		}
	}
	if($temp_wkdy >= 0) {
		if($temp_wkdy <= $#day) {
			$wkdy = $day[$temp_wkdy];
		} else {
			$wkdy = $day[0];
		}
	}
	
	return "$wkdy, $dnum-$mon-$year $time GMT";
}

###############################
# MakeNewKey - Make a new key
# file using the number passed
###############################

sub MakeNewKey {
	my ($used_key) = @_;
	open(KEYFILE, ">${admin_root{$root}}$accounts$user_id${key_file}.$used_key");
	#jumble the list
	@crypto = @password_chars;
	$ender = (rand ($max_num_iterations - $min_num_iterations)) + $min_num_iterations;
	for($t = 0; $t <= $ender; $t++) {
		for($y = 0; $y <= $#crypto; $y++) {
			$temp = $crypto[$y];
			$move_temp = rand $#crypto;
			$crypto[$y] = $crypto[$move_temp];
			$crypto[$move_temp] = $temp;
		}
	}
	for($t = 0; $t <= $#crypto; $t++) {
		print KEYFILE "$password_chars[$t],$crypto[$t]\n";
	}
	close KEYFILE;
}

###############################
# EncryptPassword - Pick a key
# (create one if necessary) and
# use it to encrypt a password
###############################
sub EncryptPassword {
	my $try_password = $password[$user_id];
	my $done_password = "";
	
	my $used_key = int (rand($max_keys) + 0.5);
	if(int(rand($key_chance) + 0.5) == 0) {
		MakeNewKey($used_key);
	}
	
	my $letter_org = $letter_rep = ' ';
	
	@temp_pass = split(//, $try_password);
	#try and use the key, if not ready, make a new one
	if(open(KEYFILE, "${admin_root{$root}}$accounts$user_id${key_file}.$used_key")) {
		@enc_key = <KEYFILE>;
		close KEYFILE;

		for($boo = 0; $boo <= $#temp_pass; $boo ++) {
			
			CONTINUE_GUY2: foreach $s (@enc_key) {
				#Strip off extra spaces
				$s =~ s/^\s+//;
				$s =~ s/\s+$//;
				#Strip off extra newlines
				$s =~ s/^\n+//;
				$s =~ s/\n+$//;
				#Split
				($letter_org, $letter_rep) = split(/,/, $s);

				#replace appropriate chars
				#I would /really/ be open to suggestions on how to do this more efficiently
				if($temp_pass[$boo] eq $letter_rep) {
					$temp_pass[$boo] = $letter_org;
					last CONTINUE_GUY2;
				}
			}
			
			#keeping the folloing code in... this is what I would like to do, but it doesnt work
			#any suggestions????
			#$try_password =~ tr/\Q$letter_rep/\Q$letter_org/;
		}
		$done_password = join("", @temp_pass);
	} else {
		MakeNewKey($used_key);
		open(KEYFILE, "${admin_root{$root}}$accounts$user_id${key_file}.$used_key");
		@enc_key = <KEYFILE>;
		close KEYFILE;
		for($boo = 0; $boo <= $#temp_pass; $boo ++) {
			CONTINUE_GUY3: foreach $s (@enc_key) {
				#Strip off extra spaces
				$s =~ s/^\s+//;
				$s =~ s/\s+$//;
				#Strip off extra newlines
				$s =~ s/^\n+//;
				$s =~ s/\n+$//;
				#Split
				($letter_org, $letter_rep) = split(/,/, $s);
				#$shell_shocked = "$shell_shocked -$letter_org-to-$letter_rep-for-$temp_pass[$boo]-<br>";
				#replace appropriate chars
				#I would /really/ be open to suggestions on how to do this more efficiently
				if($temp_pass[$boo] eq $letter_rep) {
					$temp_pass[$boo] = $letter_org;
					last CONTINUE_GUY3;
				}
			}
			
			#keeping the folloing code in... this is what I would like to do, but it doesnt work
			#any suggestions????
			#$try_password =~ tr/\Q$letter_rep/\Q$letter_org/;
		}
		$done_password = join("", @temp_pass);
	}
	
	return ($done_password, $used_key);
}

###############################
# UserLogin - Check to see if
# the user is logged in or if
# they have recently logged in.
###############################
sub UserLogin {
	undef $try_username;
	undef $try_password;

	if($posted{$form_username} & $posted{$form_password}) {
		#Just barely logged in
		$try_username = $posted{$form_username};
		$try_password = $posted{$form_password};
	} elsif($cookie{$hidden_username}) {
		#Has been logged in with encrypted cookies (mmm.... encrypted cookies....)
		$try_username = $cookie{$hidden_username};
		$try_password = DecryptPassword;
	}
	
	if(defined $try_username) {
		for($i = 0; $i <= $#username; $i++) {
			if($username[$i] eq $try_username) {
				$id = $i;
				#I should just quit here, but am a bit paranoid so I'll fix this later
			}
		}
		if($try_password eq $password[$id]) {
			#Validated.... we have a winner!
			$user_id = $id;
			#for persistent connections, set cookie data
			AddCookie($hidden_username, $username[$id], "");
			($encrypted_password, $key_used) = EncryptPassword;
			AddCookie($hidden_password, $encrypted_password, "");
			AddCookie($hidden_password_key, $key_used, "");
		} else {
			$user_id = $guest_user;
		}
	} else {
		$user_id = $guest_user;
	}
}

###############################
# UpdateAccount - given the
# information, update an acnt.
###############################
sub UpdateAccount {
	@params = @_;
	$local_id = $params[0];
	$new_name = $params[1];
	$new_pass = $params[2];
	$new_grps = $params[3];
	
	#first, we can't do this with guest
	if($local_id != $guest_user) {
		if($#username < $local_id) {
			#Hmmm... user not yet added, let's add them!
			$local_id = AddUser($new_name. $new_pass, $new_grps);
			#unfortunately, this means we cant pick UID....
		} else {
			$username[$local_id] = $new_name;
			$password[$local_id] = $new_pass;
			$groups[$local_id] = $new_grps;
			SavePasswdFile;
		}
	}
}

###############################
# UserUpdate - User can update
# their account and stuff
###############################
sub UserUpdate {
	#First, make sure we are logged as someone
	if($user_id != $guest_user) {
		#next, see if we already did all this
		undef $pass_match;
		undef $pass_small;
		undef $pass_changed;
		undef $extras_changed;
		if($posted{$form_update_password}) {
			if($posted{$form_update_password} ne $posted{$form_password_verify}) {
				$pass_match = $no;
			} else {
				$pass_match = $yes;
			}
			$temp = $posted{$form_update_password};
			$count = ($temp =~ s/./*/g);
			if($count < $min_password_size{$root}) {
				$pass_small = $yes;
			}
			if($posted{$form_update_password} ne $password[$user_id]) {
				$pass_changed = $yes;
			} else {
				$pass_changed = $no;
			}
		}
		
		if($posted{"${extra_blank}1"}) {
			if($extras_used{$root} > 0) {
				for($i = 1; $i <= $extras_used{$root}; $i++) {
					
					if(GetExtras($i, $user_id) ne $posted{"${extra_blank}${i}"}) {
						$extras_changed = $yes;
					}
				}
				if($extras_changed eq $yes) {
					AddExtras($user_id);
					print "<font size=+1 face=arial,helvetica><b><br><br>$msg_userupdate_success{$root}</b></font><br>";
				}
			}
		}
		
		if($pass_match ne $no & $pass_small ne $yes & $pass_changed eq $yes) {
			UpdateAccount($user_id, $username[$user_id], $posted{$form_update_password}, $groups[$user_id]);
			print "<font size=+1 face=arial,helvetica><b>$msg_userupdate_success{$root}</b></font><br>";
		} else {
			print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
			print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_userupdate{$root}</b></font></td><br>\n";
			if($pass_match eq $no | $pass_small eq $yes) {
				print "<td align=left valign=center bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_userupdate_error{$root}</b></font>";
			}
			print "</td></tr><td align=left>";
			print "<br><form method=\"post\" action=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_userconfig\" enctype=\"application/x-www-form-urlencoded\">\n";
			print "$msg_userupdate_instruct{$root}<br><br>\n\n";
			print "${blank_space}${blank_space}<b>$msg_userupdate_username{$root}:$username[$user_id]<b><br><br>\n";
			print "${blank_space}${blank_space}$msg_userupdate_password1{$root}<br>\n";
			print "${blank_space}<input type=\"password\" name=\"$form_update_password\" value=\"$password[$user_id]\"><br><br>\n";
			print "${blank_space}${blank_space}$msg_userupdate_password2{$root}<br>\n";
			print "${blank_space}<input type=\"password\" name=\"$form_password_verify\" value=\"$password[$user_id]\"><br><br>\n";
			for ($i = 1; $i <= $extras_used{$root}; $i++) {
				print "${blank_space}${blank_space}$msg_extra{$root}[$i]<br>\n";
				$extra_cont = GetExtras($i, $user_id);
				print "${blank_space}<input type=\"text\" name=\"${extra_blank}${i}\" value=\"$extra_cont\"><br><br>\n";
			}
			if($extras_used{$root} > 0) {
				print "$privacy_policy{$root}";
			}
			print "<br><input type=SUBMIT value=\"Submit\"> <input type=RESET value=\"Reset\"></form>";
			print "</td><td align=left valign=top>";
			if($pass_match eq $no | $pass_small eq $yes) {
				print "$msg_userupdate_errors_instruct{$root}<br><br><ul>\n\n";
				if($pass_match eq $no) {
					print "<li>$msg_userupdate_passdontmatch{$root}</li><br>\n";
				}
				if($pass_small eq $yes) {
					print "<li>$msg_userupdate_passtoosmall{$root}</li><br>\n";
				}
				print "</ul>";
			}
			print "</td></tr></table>";
		}
	} else {
		print "$user_id<br>";
	}
}

###############################
# PassRemind - Sends the user a
# garbledeegook password when
# they forget their password.
###############################
sub PassRemind {
	#First, let's make sure we ain't logged in, 'cuz that would be just silly!
	if($user_id == $guest_user) {
		#first, check to see if we already did all this
		undef $name_match;
		undef $valid_email;
		undef $valid_account;
		if($posted{$form_username}) {
			for($i = 0; $i <= $#username; $i++) {
				if($username[$i] eq $posted{$form_username}) {
					$id = $i;
					$name_match = $yes;
				}
			}
			if($id == $guest_user | $id == 0) {
				$valid_account = $no;
				$name_match = $no;
			}
			if($name_match eq $yes) {
				#now check if the person has a valid e-mail
				$my_email = GetExtras($email_remind{$root}, $id);
				if($my_email) {
					#Make a gobbledeegook password
					$#remind = -1;
					for($y = 1; $y <= $remindpassword_size{$root}; $y++) {
						$temp = rand $#remind_chars;
						$remind[$y] = $remind_chars[$temp];
					}
					$remind_pass = join("", @remind);
					
					UpdateAccount($id, $username[$id], $remind_pass, $groups[$id]);
	
					#send that puppy out
					open(MAIL, "|$mail_interface $mail_subject \"$title{$root} $msg_passremind_subject{$root}\" $my_email");
					print MAIL "$msg_passremind_head{$root}\n$remind_pass\n$msg_passremind_foot{$root}";
					close MAIL;
					print "<br><font size=+1 face=arial,helvetica><b>$msg_password_sent{$root}</b></font>";
				} else {
					$valid_email = $no;
				}
			} else {
				$name_match = $no;
			}
		}
		if($name_match ne $yes) {
			print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
			print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_passremind_dialog{$root}</b></font></td><br>\n";
			if($name_match eq $no | $valid_email eq $no | $valid_account eq $no) {
				print "<td align=left valign=center bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_passremind_dialog_error{$root}</b></font>";
			}
			print "</td></tr><td align=left>";
			print "<br><form method=\"post\" action=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_remind\" enctype=\"application/x-www-form-urlencoded\">\n";
			print "$msg_passremind_instruct{$root}<br><br>\n\n";
			print "${blank_space}${blank_space}$msg_passremind_username{$root}<br>\n";
			print "${blank_space}<input type=\"text\" name=\"$form_username\" value=\"$posted{$form_username}\"><br><br>\n";
			if($extras_used > 0) {
				print "$privacy_policy{$root}";
			}
			#print "<br>$username[0]<br>\n";
			print "<br><input type=SUBMIT value=\"Submit\"> <input type=RESET value=\"Reset\"></form>";
			print "</td><td align=left valign=top>";
			if($name_match eq $no | $valid_email eq $no | $valid_account eq $no ) {
				print "$msg_passremind_errors_instruct{$root}<br><br><ul>\n\n";
				if($name_match eq $no) {
					print "<li>$msg_passremind_nomatch{$root}</li><br>\n";
				}
				if($valid_email eq $no) {
					print "<li>$msg_passremind_emailprob{$root}</li><br>\n";
				}
				if($valid_account eq $no) {
					print "<li>$msg_passremind_badaccount{$root}</li><br>\n";
				}
				print "</ul>";
			}
			print "</td></tr></table>";
		}
	} else {
		print "$msg_already_logon{$root}";
	}
}

###############################
# LoginBox - the login box- duh
###############################
sub LoginBox {
	print "</td>";
	print " <td width=$loginbox_w{$root} valign=top align=center>";
	print "<table width=\"100%\" bgcolor=\"$AdminBGColor{$root}\" border=5 cellpadding=0 callspacing=0><tr><td>\n";
	print "<font size=+1 face=arial,helvetica><b>$msg_loginbar{$root}</b></font><br><br>\n";
	#Check if we have someone already logged in
	if($user_id != $guest_user) { #Hey, somebody is logged in!
		if($username[$user_id]) {
			print "<font size=-1>$msg_welcome{$root} $username[$user_id]</font><br>\n";
		} else {
			#Woah, we shouldn't have this happen... chances are we are dealing with a cracker in this case
			print "<font size=-1>$msg_crack{$root}</font>\n";
		}
	} else { #Nobody is logged in, so we'll extend a greeting allowing them to do so
		print "<form method=\"post\" action=\"$noink_cgi?${option_root}=$root&${present_dir_command}\" enctype=\"application/x-www-form-urlencoded\">\n";
		print "${blank_space}${blank_space}$msg_username{$root} <br>${blank_space}<input type=\"text\" name=\"$form_username\" value=\"\"><br>\n";
		print "${blank_space}${blank_space}$msg_password{$root} <br>${blank_space}<input type=\"password\" name=\"$form_password\" value=\"\"><br>\n";
		print "<br><input type=SUBMIT value=\"SUBMIT\"> <input type=RESET value=\"Reset\"></form>";
		if($users_add_own_accounts{$root} ne $no) {
			print "<font size=0 face=courier><a href=\"$noink_cgi?$option_root=$root&$cmd=$cmd_newuser\">$msg_newuser{$root}</a></font><br>\n";
		}
		if($email_remind{$root}) {
			print "<br><font size=0 face=courier><a href=\"$noink_cgi?$option_root=$root&$cmd=$cmd_remind\">$msg_email_remind{$root}</a></font>\n";
		}
	}
	print "<br><br></td></tr></table>\n";
}
1;
