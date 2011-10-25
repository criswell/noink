#noforum.pm
# Noink Forum Subroutines
#------------------------
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

##############################
# ParsePost - Load and Parse a
# post file
##############################
sub ParsePost {
	($post_file) = @_;
	open(POST, "$post_file");
	@post_data = <POST>;
	close POST;
	$content_reached = $no;
	$#whole_content = -1;
	foreach $post_line (@post_data) {
		#print "\n$post_line -blee!<br>";
		if($content_reached eq $no) {
			#print "\ncontent not reached looking for $post_content\n";
			#Strip off extra spaces
			$post_line =~ s/^\s+//;
			$post_line =~ s/\s+$//;
			#Strip off extra newlines
			$post_line =~ s/^\n+//;
			$post_line =~ s/\n+$//;
			#Strip off extra tabs
			$post_line =~ s/^\t+//;
			$post_line =~ s/\t+$//;
			%postal = split(/=/, $post_line);
			if($postal{$post_title}) {
				$this_title = $postal{$post_title};
			} elsif($postal{$post_from}) {
				$this_from = $postal{$post_from};
			} elsif($postal{$post_date}) {
				$this_date = $postal{$post_date};
			} elsif($postal{$post_ip}) {
				$this_ip = $postal{$post_ip};
			} elsif($post_line eq $post_content) {
				$content_reached = $yes;
			}
		} else {
			push(@whole_content, "$post_line");
		}
	}
	
	if($this_from == $guest_user | $this_from < 0 | $this_from > $#username) {
		$this_from = $msg_forum_guest{$root};
	} else {
		$this_from = $username[$this_from];
	}
	
	$content_done = join("\n", @whole_content);
	return ($this_title, $this_from, $content_done, $this_date, $this_ip);
}

#################################
# ForumConf - Forum Configuration
# reader and parser
#################################
sub ForumConf {
	($conf_fname) = @_;
	my $own, $ng, $md, $dp, $grp, $perm = "";
	if(open(CONF, "$conf_fname")) {
		@config_file = <CONF>;
		close CONF;
		$cur_section = $conf_null;
		$ng = $no;
		$dp = $default_forum_depth{$root};
		undef $md;
		#undef $bd;
		#undef $bt;
		#undef $bn;
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
			if ($cur_section eq $conf_null) {
				if ($config_line eq $forum_conf) {
						$cur_section = $forum_conf;
				}
			} else {
				if ($config_line eq "${cur_section}${conf_end}" | $config_line eq "${cur_section}${conf_null}") {
					$cur_section = $conf_null;
				} else {
					%conf = split(/$conf_split/,$config_line);
					if($conf{$forum_noguest}) {
						$ng = $yes;
					} elsif ($conf{$forum_moderator}) {
						$md = $conf{$forum_moderator};
					} elsif ($conf{$forum_deep}) {
						$dp = $conf{$forum_deep};
					} elsif ($conf{$conf_owner}) {
						$own = $conf{$conf_owner};
					} elsif ($conf{$conf_group}) {
						$grp = $conf{$conf_group};
					} elsif ($conf{$conf_permissions}) {
						$perm = $conf{$conf_permissions};
					}
					# Legacy code - hope to reimpliment
					 # elsif ($conf{$forum_bydate}) {
					#	$bd = $conf{$forum_bydate};
					#} elsif ($conf{$forum_bytitle}) {
					#	$bt = $conf{$forum_bytitle};
					#} elsif ($conf{$forum_byname}) {
					#	$bn = $conf{$forum_byname};
					#}
				}
			}
		}
	} else {
		print "$msg_nodata{$root}\n";
	}
	
	#if(!$bd & !$bt & !$bn) {
		#Default with descending by date (i.e., most recent, first)
	#	$bd = $form_descend;
	#}
	return($ng, $md, $dp, $own, $grp, $perm); #, $bd, $bt, $bn);
}

##################################
# ForumHeader - Display the forum
# header (basically a command bar)
##################################
sub ForumHeader {
	my ($extra_cmd, $sub_msg, $sforum) = @_;
	print "<table width=\"100%\" cols=3 border=0 cellpadding=\"2\" cellspacing=\"2\" nosave>\n";
	print "<tr><td align=center bgcolor=$forum_header_BGColor{$root}>";
	if($groups[$user_id] =~ /$f_group/) {
		print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_delthread}&${option_msg}=${sub_msg}";
		if($sforum) {
			print "&${option_subforum}=${sforum}";
		}
		print "$extra_cmd\">$msg_forum_delthread{$root}</a> ";
	}
	print "#:$sub_msg</td><td align=center bgcolor=$forum_header_BGColor{$root}>";
	print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_new}$extra_cmd\">$msg_forum_new{$root}</a></td>";
	if($sub_msg) {
		print "<td align=center bgcolor=$forum_header_BGColor{$root}>";
		if($sforum) {
			print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_reply}&${option_msg}=${sub_msg}&${option_subforum}=${sforum}$extra_cmd\">$msg_forum_reply{$root}</a></td>";
		} else {
			print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_reply}&${option_msg}=${sub_msg}$extra_cmd\">$msg_forum_reply{$root}</a></td>";
		}
	}
	print "</td></tr></table>\n";
}

############################
# AddPost - Add the post the
# user just entered
############################
sub AddPost {
	my $posted_id = $posted{$form_hidden_id};
	my $posted_date = $posted{$form_hidden_date};
	my $msgnum = $posted{$form_hidden_msgnum};
	my $subfor = $posted{$form_hidden_submsg};
	my $extra_cmd = "";
	if($option{$option_index_dir} eq $option_index_archive) {
		$cur_root_dir = $site_archive_root{$root};
		$cur_data_root = $archive_root{$root};
		$extra_cmd = "&$option_index_dir=$option_index_archive";
	} else {
		$cur_root_dir = $site_root{$root};
		$cur_data_root = $data_root{$root};
	}

	if($subfor) {
		$working_dir = "$cur_data_root${forum_location}${forum_posts}$subfor${forum_posts}";
	} else {
		$working_dir = "$cur_data_root${forum_location}${forum_posts}";
	}
	if($msgnum) {
		$working_dir = "$working_dir${msgnum}$forum_posts";
	}
	my $title = $posted{$form_title};
	my $content = $posted{$form_content};
	my $ip = $ENV{'REMOTE_ADDR'};
	#process HTML tags
	$content=~ s!&#060/a&#062!</a>!g;
	$content=~ s/&#060a href="/<a href="/g;
	$content=~ s/"&#062/">/g;
	$content=~ s/&#060b&#062/<b>/g;
	$content=~ s/&#060u&#062/<u>/g;
	$content=~ s/&#060i&#062/<i>/g;
	$content=~ s|&#060/b&#062|</b>|g;
	$content=~ s|&#060/u&#062|</u>|g;
	$content=~ s|&#060/i&#062|</i>|g;
	
	#First, we must be the same user!
	print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}$extra_cmd\">";
	if($posted_id == $user_id) {
		#next, we must have everything!
		if($posted_date, $title, $content) {
			if(open(POSTCNT, "$working_dir${post_num}")) {
				$total_posts = <POSTCNT>;
				close POSTCNT;
			} else {
				$total_posts = 0;
				mkdir "$working_dir", 0700;
			}
			$cur_post = $total_posts + 1;
			open(POST, ">$working_dir$cur_post");
			print POST "$post_title${conf_split}$title\n";
			print POST "$post_from${conf_split}$posted_id\n";
			print POST "$post_date${conf_split}$posted_date\n";
			print POST "$post_ip${conf_split}$ip\n";
			print POST "$post_content\n";
			print POST "$content\n";
			close POST;
			open(POSTCNT, ">$working_dir${post_num}");
			print POSTCNT "$cur_post";
			close POSTCNT;
			print "$msg_post_success{$root}<br>\n";
		} else {
			print "$msg_post_error_notfill{$root}<br>\n";
		}
	} else {
		print "$msg_post_error_wrongid{$root}<br>\n";
	}
	print "</a>";
}

###############################
# DeleteThread - Delete a forum
# thread.
###############################
sub DeleteThread {
	my ($workdir, $depth, $msg_num, $sub_for, $extra_cmd) = @_;
	if($posted{$delthread}) {
		if($groups[$user_id] =~ /$f_group/) {
			if($posted{$delthread} eq $no) {
				print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}$extra_cmd\">$msg_forum_delcancel{$root}</a><br>\n";
			} else {
				my $loc_msg1 = `$delete_rec_f $workdir$msg_num`;
				my $loc_msg2 = `$delete_rec_f $workdir$msg_num$forum_posts`;
				print "<br>$loc_msg1<br>\n$loc_msg2<br>\n";
				print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}$extra_cmd\">$msg_forum_deldone{$root}</a><br>\n";
			}
		} else {
			print "$msg_sorry_adminonly{$root}<br>\n";
		}
	} else {
		if($groups[$user_id] =~ /$f_group/) {
			print "<form method=\"post\" action=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_delthread}&${option_msg}=${msg_num}";
			if($sub_for) {
				print "&${option_subforum}=${sub_for}";
			}
			print "$extra_cmd\" enctype=\"application/x-www-form-urlencoded\">\n";
			DisplayPost($workdir, $msg_num, $depth, $no, $sub_for, $extra_cmd);
			print "<br><center><b>$msg_forum_delsure{$root} </b><select name=\"$forum_delthread{$root}\">\n";
			print "<option value=\"$no\">$no\n";
			print "<option value=\"$yes\">$yes\n";
			print "</select>$blank_space$blank_space$blank_space<input type=submit value=\"Submit\"></center>";
			print "</form>";
		} else {
			print "$msg_sorry_adminonly{$root}<br>\n";
		}
	}
}

###############################
# ClearForum - clear the forum
###############################
sub ClearForum {
	my ($del_dir, $extra_cmd) = @_;
	if($posted{$delthread}) {
		if($groups[$user_id] =~ /$f_group/) {
			if($posted{$delthread} eq $no) {
				print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}$extra_cmd\">$msg_forum_delcancel{$root}</a><br>\n";
			} else {
				my $loc_msg1 = `$delete_rec_f $del_dir`;
				print "<br>$loc_msg1<br>\n";
				print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}$extra_cmd\">$msg_forum_deldone{$root}</a><br>\n";
			}
		} else {
			print "$msg_sorry_adminonly{$root}<br>\n";
		}
	} else {
		if($groups[$user_id] =~ /$f_group/) {
			print "<form method=\"post\" action=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_clear}$extra_cmd\" enctype=\"application/x-www-form-urlencoded\">\n";
			print "<br><center><b>$msg_forum_clearsure{$root} </b><select name=\"$forum_delthread{$root}\">\n";
			print "<option value=\"$no\">$no\n";
			print "<option value=\"$yes\">$yes\n";
			print "</select>$blank_space$blank_space$blank_space<input type=submit value=\"Submit\"></center>";
			print "</form>";
		} else {
			print "$msg_sorry_adminonly{$root}<br>\n";
		}
	}
}
###################################
# PostMsg - Post/Reply to a message
###################################
sub PostMsg {
	my ($msg_num) = @_;
	print "<table width=\"100%\" cols=1 border=0 cellpadding=\"2\" cellspacing=\"2\" nosave>\n";
	print "<tr><td align=center bgcolor=$forum_header_BGColor{$root}>";
	my $extra_cmd = "";
	if($option{$option_index_dir} eq $option_index_archive) {
		$cur_root_dir = $site_archive_root{$root};
		$cur_data_root = $archive_root{$root};
		$extra_cmd = "&$option_index_dir=$option_index_archive";
	} else {
		$cur_root_dir = $site_root{$root};
		$cur_data_root = $data_root{$root};
	}
	if ($msg_num) {
		#If this is set, we are replying to a message
		print "$msg_forum_reply{$root}</td></tr></table>\n";
		my $subfor = $option{$option_subforum};
		if($subfor) {
			$working_dir = "$cur_data_root${forum_location}${forum_posts}$subf${forum_posts}";
		} else {
			$working_dir = "$cur_data_root${forum_location}${forum_posts}";
		}
		DisplayPost($working_dir, $msg_num, 0, $yes, $subfor);
		
	} else {
		print "$msg_forum_new{$root}</td></tr></table>\n";
	}
	
	my $curdate = `$date_general`;
	my $uname = $username[$user_id];
	if($user_id == $guest_id) {
		$uname = $msg_forum_guest{$root};
	}
	print "<table width=\"100%\" cols=1 border=0 cellpadding=0 cellspacing=0 nosave>\n";
	print "<tr><td align=center bgcolor=$forum_post_BGColor{$root}>";
	print "<font face=arial,helvetica><b>$msg_forum_from{$root} <i>$username[$user_id]</i> $msg_forum_date{$root} <i>$curdate</i></b></font>\n\n";
	print "</td></tr></table>\n";
	print "<form method=\"post\" action=\"$noink_cgi?${option_root}=$root&${option_dir}=$option{$option_dir}&$cmd=$cmd_forum&${forum_cmd}=${forum_addpost}$extra_cmd\" enctype=\"application/x-www-form-urlencoded\">\n";
	#first hide some fields
	print "<input type=\"hidden\" name=\"$form_hidden_id\" value=\"$user_id\">\n";
	print "<input type=\"hidden\" name=\"$form_hidden_date\" value=\"$curdate\">\n";
	print "<input type=\"hidden\" name=\"$form_hidden_msgnum\" value=\"$msg_num\">\n";
	print "<input type=\"hidden\" name=\"$form_hidden_submsg\" value=\"$option{$option_subforum}\">\n";
	
	my $new_title = "";
	
	#set the default reply
	if ($msg_num) {
		my ($title, $from, $content, $tdate, $ip) = ParsePost("$working_dir$msg_num");
		$new_title = "$forum_reply_pre{$root}$title";
	}
	print "<input type=\"text\" name=\"$form_title\" size=40 value=\"$new_title\">\n\n";
	print "<textarea name=\"$form_content\" rows=25 cols=80></textarea><br>\n";
	print "$msg_forum_validhtml{$root_sites[0]}<br>\n";
	print "<input type=\"submit\" name=\"Submit\"><input type=\"reset\" name=\"Clear\"><br>\n";
	print "</form>";
}

################################
# ForumMain - The main interface
# to the forum system
################################
sub ForumMain {
	$forum_location = $option{$option_dir};
	$fcommand = $option{$forum_cmd};
	$fmsg = $option{$option_msg};
	$subf = $option{$option_subforum};
	my $extra_cmd = "";
	if($option{$option_index_dir} eq $option_index_archive) {
		$cur_root_dir = $site_archive_root{$root};
		$cur_data_root = $archive_root{$root};
		$extra_cmd = "&$option_index_dir=$option_index_archive";
	} else {
		$cur_root_dir = $site_root{$root};
		$cur_data_root = $data_root{$root};
	}
	ProcessConf("$cur_data_root${forum_location}$forum_file");
	($noguest, $moderator, $deep, $f_owner, $f_group, $f_permissions) = ForumConf("$cur_data_root${forum_location}$forum_file");
	if($groups[$user_id] =~ /$f_group/) {
		if($fcommand ne $forum_delthread && $fcommand ne $forum_clear) {
			print "<center><b><a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_clear}$extra_cmd\">$msg_forum_clear{$root}</a></b></center><br>";
		}
	}	
	
	#would do user customizations here, but for now, we use defaults
	$perscreen = $default_forum_perscreen{$root};
	
	#Get all the filenames in the sub-directory
	if(opendir(POSTS, "$cur_data_root${forum_location}${forum_posts}")) {
		closedir POSTS;
	} else {
		#Directory does not exist, must create it.
		mkdir "$cur_data_root${forum_location}${forum_posts}", 0700;
	}
	if($subf) {
		$working_dir = "$cur_data_root${forum_location}${forum_posts}$subf${forum_posts}";
	} else {
		$working_dir = "$cur_data_root${forum_location}${forum_posts}";
	}	
	if($fcommand eq $forum_new) {
		if($user_id == $guest_user && $fourm_other_posts{$root} eq $no) {
			print "$msg_forum_noother{$root}<br>\n";
		} else {
			PostMsg;
		}
	} elsif($fcommand eq $forum_reply) {
		if($user_id == $guest_user && $fourm_other_posts{$root} eq $no) {
			print "$msg_forum_noother{$root}<br>\n";
		} else {
			PostMsg($fmsg);
		}
	} elsif($fcommand eq $forum_addpost) {
		if($user_id == $guest_user && $fourm_other_posts{$root} eq $no) {
			print "$msg_forum_noother{$root}<br>\n";
		} else {
			AddPost;
		}
	} elsif($fcommand eq $forum_delthread) {
		DeleteThread($working_dir, $deep, $fmsg, $subf, $extra_cmd);
	} elsif($fcommand eq $forum_clear) {
		ClearForum("$cur_data_root$forum_location$forum_posts", $extra_cmd);
	} else {
		#Find out how many posts are in this directory
		if(open(POSTCNT, "$working_dir${post_num}")) {
			$total_posts = <POSTCNT>;
			close POSTCNT;
		} else {
			$total_posts = 0;
		}
		
		if($total_posts == 0) {
			ForumHeader($extra_cmd);
			print "$msg_forum_empty{$root}<br>\n";
		} else {
			if($fmsg) {
				if($fcommand ne $forum_more) {
					ForumHeader($extra_cmd, $fmsg, $subf);
					DisplayPost($working_dir, $fmsg, $deep, $yes, $subf, $extra_cmd);
				} else {
					if($fcommand eq $forum_more) {
						$last_post = $fmsg - $perscreen;
						$first_post = $fmsg;
					} else {
						$last_post = $total_posts - $perscreen;
						$first_post = $total_posts;
					}
				
					if($last_post < 1) {
						$last_post = 1;
					}
					for($t = $first_post; $t >= $last_post; $t--) {
						if(open(POST, "$working_dir$t")) {
							#To account for my sloppy delete!
							close POST;
							ForumHeader($extra_cmd, $t, $subf);
							DisplayPost($working_dir, $t, $deep, $yes, $subf, $extra_cmd);
						}
					}
					if($last_post > 1) {
						if($subf) {
							print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_more}&${option_msg}=${last_post}&${option_subforum}=${sforum}$extra_cmd\">$msg_forum_more{$root}</a></td>";
						} else {
							print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_more}&${option_msg}=${last_post}$extra_cmd\">$msg_forum_more{$root}</a></td>";
						}
					}
				}
			} else {
				$last_post = $total_posts - $perscreen;
				$first_post = $total_posts;
				
				if($last_post < 1) {
					$last_post = 1;
				}
				for($t = $first_post; $t >= $last_post; $t--) {
					if (open(POST, "$working_dir$t")) {
						#This accounts for my sloppy delete! ;)
						close POST;
						ForumHeader($extra_cmd, $t, $subf);
						DisplayPost($working_dir, $t, $deep, $yes, $subf, $extra_cmd);
					}
				}
				if($last_post > 1) {
					if($subf) {
						print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_more}&${option_msg}=${last_post}&${option_subforum}=${sforum}$extra_cmd\">$msg_forum_more{$root}</a></td>";
					} else {
						print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${forum_cmd}=${forum_more}&${option_msg}=${last_post}$extra_cmd\">$msg_forum_more{$root}</a></td>";
					}
				}
			}
		}
	}
}

##########################
# DisplayPost - Load and
# display a post
##########################
sub DisplayPost {
	my ($workdir, $postnum, $depth, $disp_cont, $sforum, $extra_cmd) = @_;
	foreach ($workdir, $postnum, $depth, $disp_cont, $sforum) {
		#Strip off extra spaces
		s/^\s+//;
		s/\s+$//;
		#Strip off extra newlines
		s/^\n+//;
		s/\n+$//;
		# Convert %32 character codes into the characters
		#s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	}
	my ($title, $from, $content, $tdate, $ip) = ParsePost("$workdir$postnum");
	if($tdate) {
		if($disp_cont ne $no) {
			print "<table width=\"100%\" columns=1 cellspacing=0 cellpadding=0 border=0><tr><td align=left bgcolor=$forum_post_BGColor{$root}>";
		} else {
			print "<table width=\"100%\" columns=1 cellspacing=0 cellpadding=0 border=0><tr><td align=left>";
		}
		print "<font face=arial,helvetica><b>$msg_forum_title{$root} <i>$title</i></b><br>\n";
		print "<b>$msg_forum_from{$root} <i>$from</i> $msg_forum_date{$root} <i>$tdate</i></b></font>\n\n";
		print "</td></tr><tr><td align=left><br>";
		if($disp_cont ne $no) {
			print "$content<br>\n";
		} else {
			print "<a href=\"${noink_cgi}?${option_root}=$root&${cmd}=${cmd_forum}&${option_dir}=$option{$option_dir}&${option_subforum}=${sforum}&${option_msg}=${postnum}$extra_cmd\">$msg_click_here{$root}</a>";
		}
	
		if($depth > 0) {
			if(open(POSTCNT, "$workdir$postnum$forum_posts${post_num}")) {
				my $tposts = <POSTCNT>;
				close POSTCNT;
				my $last_tpost = $tposts - $forum_max_inner{$root};
				if ($last_tpost < 1) {
					$last_tpost = 1;
				}
				for(my $i = $tposts; $i >= $last_tpost; $i--) {
					if($tposts > 0) {
						print "<blockquote>";
						my $next_level = "$postnum";
						if($sforum) {
							$next_level = "$sforum$forum_posts$postnum";
						}
						DisplayPost("$workdir$postnum$forum_posts", $i, $depth-1, $no, $next_level, $extra_cmd);
						print "</blockquote>";
					}
				}
			}
		}
		print "</td></tr></table>\n";
	}
}

1;