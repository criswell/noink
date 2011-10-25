# nonewslib.pm
# ------------
# NoNews Library Functions
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

####################
# StartHTML - Begin
# an HTML session
####################
sub StartHTML {
	print $co->header;
	# I know I could just have CGI.pm handle all this, but I have very specific needs CGI.pm cannot address
	print "<html>\n<head>\n";
	print "\<title>\n";
	print GetElement($noml_title, %Config);
	print "</title>\n";
	foreach $tag (@HTML_metas) {
		my $temp = GetElement($tag, %Config);
		if($temp) {
			print "<meta name=\"$tag\" content=\"$temp\">\n";
		}
	}
	# Aquire CSS stuff with regards to theme
	$CSS_Src = GetElement("${Theme}.${noml_css}", %Config);
	if($CSS_Src) {
		print "<link rel=\"STYLESHEET\" type=\"text/css\" href=\"$CSS_Src\">\n";
	}
	
	print "</head>\n\n<body ";
	foreach $tag (@BODY_metas) {
		my $temp = GetElement("${Theme}.${noml_body}.${tag}", %Config);
		if($temp) {
			print " $tag=\"$temp\" \n";
		}
	}
	
	print " >\n\n";
	BannerDisplay;
	print "\n\n <center>\n\n<table ";
	foreach $tag (@Table_metas) {
		my $temp = GetElement("${Theme}.${noml_MainTable}.${tag}", %Config);
		if($temp) {
			print " $tag=\"$temp\" \n";
		}
	}
	
	print " >\n\n";
}

#################
# EndHTML - End
# an HTML session
#################
sub EndHTML {
	print "</table>\n";
	print $co->end_html;
}

########################
# BreakingNews - Display
# the breaking news
# section. This section
# does not archive...
# you can think of this
# as the head of the
# document
########################
sub BreakingNews {
	my ($work_dir) = @_;
	print "\n <center> \n\n<!--- BREAKING NEWS SECTION --->\n\n";
	print "<table ";
	
	my $bord_w = GetElement("${Theme}.${noml_BreakingNews}.${noml_borderw}", %Config);
	
	if($bord_w) {
		# Here, we will only be using one color... if there is a list, then you are
		# using this section of the code incorrectly!
		my $bord_c = GetElement("${Theme}.${noml_BreakingNews}.${noml_borderc}", %Config);
		print " bgcolor=\"$bord_c\" CELLSPACING=\"0\" CELLPADDING=";
		my $cel_pad = $bord_w - 1;
		print "\"$cel_pad\" WIDTH=";
		my $temp = GetElement("${Theme}.${noml_BreakingNews}.width", %Config);
		print "\"$temp\"  BORDER=\"0\" ><TR><TD COLSPAN=2>\n";
		
		print "<table ";
		$bord_c = GetElement("${Theme}.${noml_BreakingNews}.bgcolor", %Config);
		print " bgcolor=\"$bord_c\" CELLSPACING=\"0\" CELLPADDING=\"$bord_w\" WIDTH=";
		print "\"100%\"  BORDER=\"0\"";
	} else {
		foreach $tag (@Table_metas) {
			my $temp = GetElement("${Theme}.${noml_BreakingNews}.${tag}", %Config);
			if($temp) {
				print " $tag=\"$temp\" \n";
			}
		}
	}
	
	print " >\n\n";
	
	# Breaking news will always only have those that are numbered here
	# Breaking news also does not allow for topix or for forums - just
	# straight through HTML here... so be careful!
	my $numc = GetElement("${noml_BreakingNews}.${noml_cols}", %Config);
	my $numr = GetElement("${noml_BreakingNews}.${noml_rows}", %Config);
	if( ($numr > 0) & ($numc > 0) ) {
		for($r = 1; $r <= $numr; $r++) {
			print "<tr ";
			foreach $tag (@TR_metas) {
				my $temp = GetElement("${Theme}.${noml_BreakingNews}.${noml_TR}.${tag}", %Config);
				if($temp) {
					print " $tag=\"$temp\" \n";
				}
			}
			print " >\n\n";
			for($c = 1; $c <= $numc; $c++) {
				print "<td ";
				foreach $tag (@TD_metas) {
					my $temp = GetElement("${Theme}.${noml_BreakingNews}.${noml_TD}.${tag}", %Config);
					if($temp) {
						print " $tag=\"$temp\" \n";
					}
				}
				print " >\n\n";
				if(open(SRC, "${Data_Dir}${work_dir}/${r}/${c}/src.index")) {
					my @src = <SRC>;
					foreach $s (@src) {
						print "$s\n";
					}
					close SRC;
				}
				print "</td>\n";
			}
			print "</tr>\n";
		}
	}
	
	if($bord_w) {
		print "</table>\n</td></tr>\n";
	}
	
	print "</table>\n\n<!--- END BREAKING NEWS SECTION --->\n";
}

########################
# StripHTML - Takes
# a source HTML array &
# strips the tags not
# specified away from
# it. Returns naked src
########################
sub StripHTML {
	my ($max_chars, @src) = @_;
	
	my @naked = ();
	$#naked = -1;
	my $num_chars = 0;
	
	#Many thanks to rlk @ http://www.perlmonks.com/index.pl?node_id=46815&lastnode_id=864
	foreach $line (@src) {
		#With $_ holding the HTML text...
	
		#Pull comments.  Note that
		# `<!-- foo="--> bar <--" -->' will NOT strip ` bar '.
		# I claim this to be a feature.
		$line =~ s/<!--.*?-->//g;
	
		#for comments like <blah blah="blah" blah='blah' ... >,
		# strip from after the start of the tag  up to the end
		# of the first quoted string, repeatedly, ending in either
		# `<>' or `<no quotes here>'
		# Update: Now handles either quote char, with the other
		#        possibly within the quoted string.
		while (   $line=~s/<(?!--)[^'">]*"[^"]*"/</g
        		or $line=~s/<(?!--)[^'">]*'[^']*'/</g) {};


		#strip HTML tags without quotes in them... which should be
		# the only kind that we have left.
		$line=~s/<(?!--)[^">]*>//g;
		
		$num_chars += length($line);
		if($num_chars < $max_chars) {
			push (@naked, $line);
		}
	}
	
	push(@naked, "....");
	
	#Check to see if we ended early
	if($num_chars < $max_chars) {
		my $diff_chars = $max_chars - $num_chars;
		#print "$diff_chars is diff chars here! \n<br>";
		my $temp_space = "";
		for($i = 1; $i < $diff_chars; $i++) {
			$temp_space = "${temp_space} $HTML_whitespace";
		}
		push(@naked, $temp_space);
	}
	
	return(@naked);
}

########################
# HeadLines - Display
# the headlines
# section. This section
# does archive
########################
sub HeadLines {
	my ($work_dir, $upper_lines, $lower_lines, $lower_width) = @_;
	print "<tr><td>";
	print "\n <center> \n\n<!--- HEADLINES SECTION --->\n\n";
	#print "$lower_width lower width!\n<br>";
	my $cur_line = 0;
	my $cur_col = 0;
	my $cur_art = 0;
	
	# This is just temp until we define something better for the lower cols
	my $lower_cols = $lower_width;
	
	my $upper_char_max = GetElement("${Theme}.${noml_HeadLines}.${noml_head}.${noml_max}", %Config);
	my $lower_char_max = GetElement("${Theme}.${noml_HeadLines}.${noml_body}.${noml_max}", %Config);
	
	#my $max = GetElement("${Theme}.${noml_HeadLines}.${noml_max}", %Config);
	my $fontface = GetElement("${Theme}.${noml_HeadLines}.${noml_fontface}", %Config);
	
	my $bord_w = GetElement("${Theme}.${noml_HeadLines}.${noml_borderw}", %Config);
	my @bord_c = GetElements("${Theme}.${noml_HeadLines}.${noml_borderc}", %Config);
	my $bord_cur_col = 0;
	my @backg_c = GetElements("${Theme}.${noml_HeadLines}.${noml_bgcolor}", %Config);
	my $backg_cur_col = 0;
	my @text_c = GetElements("${Theme}.${noml_HeadLines}.${noml_textcolor}", %Config);
	my $text_cur_col = 0;
	my @bord_text_c = GetElements("${Theme}.${noml_HeadLines}.${noml_bordertextcolor}", %Config);
	my $bord_text_cur_col = 0;
	
	#print "${Data_Dir}${work_dir}/nonews.dat is where I goin\n<br>";
	if(open(SRC, "${Data_Dir}${work_dir}/nonews.dat")) {
		#print "I found!\n<br>";
		my @temp = <SRC>;
		close SRC;
		my %Local_Config = ParseXML_PreLoaded(@temp);
		my $num_art = GetElement($noml_max, %Local_Config);
		#print "num art is $num_art\n<br>";
		if(! $num_art) {
			$num_art = -1;
			#print "<center>$text_no_posts</center>\n";
		}
		if($co->param($param_cmd) eq $param_more) {
			$num_art = $co->param($param_num);
		}
		for($cur_art = $num_art; $cur_art >= 0; $cur_art--) {
			#print "$cur_art<br>\n";
			if ($cur_line == $upper_lines) {
				my $tempy_w = GetElement("${Theme}.${noml_HeadLines}.width", %Config);
				print "</table><center><table WIDTH=\"$tempy_w\"><tr><td>\n";
				$cur_line++;
			}
			
			print "<table ";
			if($bord_w) {
				print " bgcolor=\"$bord_c[$bord_cur_col]\" CELLSPACING=\"0\" CELLPADDING=";
				$bord_cur_col++;
				if($bord_cur_col > $#bord_c) {
					$bord_cur_col = 0;
				}
				my $cel_pad = $bord_w - 1;
				print "\"$cel_pad\" ";
				my $temp_w = GetElement("${Theme}.${noml_HeadLines}.width", %Config);
				#if($cur_line >= $upper_lines) {
				#	my $extreme_temp_cols = 100 / $lower_cols; #/
				#	$extreme_temp_cols = int($extreme_temp_cols);
				#	$temp_w = "${extreme_temp_cols}%";
				#}
				print "WIDTH=\"$temp_w\"  BORDER=\"0\" ><TR><TD COLSPAN=2>\n";
		
				print "<table ";
				if($#backg_c > -1) {
					print " bgcolor=\"$backg_c[$backg_cur_col]\" ";
					$backg_cur_col++;
					if($backg_cur_col > $#backg_c) {
						$backg_cur_col = 0;
					}
				}
				print "CELLSPACING=\"0\" CELLPADDING=\"$bord_w\" WIDTH=";
				print "\"100%\"  BORDER=\"0\"";
			} else {
				foreach $tag (@Table_metas) {
					my $temp_t = GetElement("${Theme}.${noml_HeadLines}.${tag}", %Config);
					if($temp_t) {
						print " $tag=\"$temp_t\" \n";
					}
				}
			}
	
			print " >\n\n";
			print "<tr ";
			foreach $tag (@TR_metas) {
				my $temp = GetElement("${Theme}.${noml_HeadLines}.${noml_TR}.${tag}", %Config);
				if($temp) {
					print " $tag=\"$temp\" \n";
				}
			}
			print " >";
			print "<td ";
			foreach $tag (@TD_metas) {
				my $temp = GetElement("${Theme}.${noml_HeadLines}.${noml_TD}.${tag}", %Config);
				if($temp) {
				print " $tag=\"$temp\" \n";
				}
			}
			print " >\n\n";
			
			#print "$cur_art now\n<br>";
			
			my %indiv_conf = ParseXML("${Data_Dir}${work_dir}/$cur_art/nonews.dat");
			my $post_day = GetElement($noml_date, %indiv_conf);
			my $post_auth = GetElement($noml_author, %indiv_conf);
			my $post_topic = GetElement($noml_topic, %indiv_conf);
			my $post_title = GetElement($noml_title, %indiv_conf);
			my $replies = GetElement($noml_max, %indiv_conf);
			my @post_keys = GetElements($noml_keywords, %indiv_conf);
			
			#Topic Icon
			if($post_topic) {
				print "<a href=\"${location_nonews}?";
				if($co->param($param_conf_prefix)) {
					my $temp_pref = $co->param($param_conf_prefix);
					print "$param_conf_prefix=$temp_pref&";
				}
				print "$param_cmd=$param_search&$param_bytopic=$post_topic\">";
				print "\n<img src=\"${location_topics}$post_topic";
				if($cur_line >= $upper_lines) {
					print "${prefix_mini}";
				}
				print "${extension_topic}\" border=0 align=left alt=\"Topic: $post_topic\"></a>";
			}
			
			#Title
			print "<font ";
			if($fontface) {
				print "face=\"$fontface\" ";
			}
			if($#text_c > -1) {
				print "color=\"$text_c[$text_cur_col]\" ";
				$text_cur_col++;
				if($text_cur_col > $#text_c) {
					$text_cur_col = 0;
				}
			}
			print ">\n";
			if($post_title) {
				print "<font size=+2>";
				print "<a ";
				if($CSS_Src) {
					print "class=\"$CSS_TitleLink\" ";
				}
				print "href=\"${location_nonews}?";
				if($co->param($param_conf_prefix)) {
					my $temp_pref = $co->param($param_conf_prefix);
					print "$param_conf_prefix=$temp_pref&";
				}
				print "$param_cmd=$param_read&$param_dir=$work_dir&$param_num=$cur_art&$param_max=$num_art\">";
				print "$post_title</a></font><br>\n";
			}
			
			#Posted by
			print "<small>by <a href=\"${location_nonews}?";
			if($co->param($param_conf_prefix)) {
				my $temp_pref = $co->param($param_conf_prefix);
				print "$param_conf_prefix=$temp_pref&";
			}
			print "$param_cmd=$param_info&$param_name=$post_auth\">$post_auth</a> on $post_day</small><br><br>\n";
			
			#segment of message relevent to this section
			
			#Load the index file
			#print "trying ${Data_Dir}${work_dir}/$cur_art/src.index <br>\n";
			if(open(SRC, "${Data_Dir}${work_dir}/$cur_art/src.index") ) {
				my @src = <SRC>;
				close SRC;
				if ($cur_line < $upper_lines) {
					@src = StripHTML($upper_char_max, @src);
				} else {
					@src = StripHTML($lower_char_max, @src);
				}
				
			        foreach $s (@src) {
					print "$s\n";
			        }
			}
			
			# end the message section
			print "</font>\n";
			if($bord_w) {
				print "</td></tr></table>\n";
			} else {
				print "<br>";
			}
			print "<font ";
			if($fontface) {
				print "face=\"$fontface\" ";
			}
			if($#bord_text_c > -1) {
				print "color=\"$bord_text_c[$bord_text_cur_col]\" ";
				$bord_text_cur_col++;
				if($bord_text_cur_col > $#bord_text_c) {
					$bord_text_cur_col = 0;
				}
			}
			print "><div align=right>";
			
			#Number of posts bellow thresh hold
			if($replies) {
				print "[ $text_replies${replies} ] ";
			}
			
			#Keyword (similar) search
			if($#post_keys > -1) {
				my $loc_keys = join("+", @post_keys);
				#print "The keys are\n<br>";
				#foreach $b (@post_keys) {
				#	print "$b\n<br>";
				#}
				print "[ <a ";
				if($CSS_Src) {
					print "class=\"$CSS_BorderLink\" ";
				}
				print "href=\"${location_nonews}?$param_cmd=$param_search&$param_dir=$work_dir&$param_bykeywords=$loc_keys";
				if($co->param($param_conf_prefix)) {
					my $temp_pref = $co->param($param_conf_prefix);
					print "$param_conf_prefix=$temp_pref&";
				}
				print "\">$text_similar_search</a> ] ";
			}
			
			#Read More
			print "[ <a ";
			if($CSS_Src) {
				print "class=\"$CSS_BorderLink\" ";
			}
			print "href=\"${location_nonews}?";
			if($co->param($param_conf_prefix)) {
				my $temp_pref = $co->param($param_conf_prefix);
				print "$param_conf_prefix=$temp_pref&";
			}
			print "$param_cmd=$param_read&$param_dir=$work_dir&$param_num=$cur_art&$param_max=$num_art\">";
			print "$text_more</a> ]</font>\n";
			
			print "</td></tr></table>\n\n";
			
			#Check if we are above or bellow
			if($cur_line < $upper_lines) {
				#print "<br></td></tr><tr><td>";
				print "<br>";
				$cur_line++;
			} else {
				print "</td>";
				$cur_col++;
				if($cur_col >= $lower_width) {
					print "</tr><tr>";
					$cur_col = 0;
					$cur_line++;
					if($cur_line > $lower_lines) {
						#Peace... we out
						if($cur_art > 0) {
							$num_left = $cur_art+1;
							print "<td>[ $text_more_posts${num_left} ] [ <a ";
							if($CSS_Src) {
								print "class=\"$CSS_MoreLink\" ";
							}
							print "href=\"${location_nonews}?";
							if($co->param($param_conf_prefix)) {
								my $temp_pref = $co->param($param_conf_prefix);
								print "$param_conf_prefix=$temp_pref&";
							}
							print "$param_cmd=$param_more&$param_dir=$work_dir&$param_num=$cur_art\">";
							print "$text_more</a> ]</td>\n";
						}
						$cur_art = -1;
					}
				}
				print "<td>";
			}
		}
	}
	print "</td></tr></center></td></tr>\n\n<!--- END HEADLINES SECTION --->\n";
}

########################
# PostHeader : Take the
# user owner list, the
# group owner list,
# and generate a
# posting header
########################
sub PostHeader {
	my ($replies, @user_owner, @group_owner) = @_;
	
	my $loc_dir = $co->param($param_dir);
	my $loc_num = $co->param($param_num);
	my $loc_max = $co->param($param_max);
		
	my $fontface = GetElement("${Theme}.${noml_HeadLines}.${noml_fontface}", %Config);

	my $bord_w = GetElement("${Theme}.${noml_HeadLines}.${noml_borderw}", %Config);
	
	my @bord_c = GetElements("${Theme}.${noml_HeadLines}.${noml_borderc}", %Config);
	my $cur_bord_c = 0;
	if( ($loc_max >= $loc_num) & ($#bord_c > -1) ) {
		my $diffo = $loc_max - $loc_num;
		$cur_bord_c = $diffo%($#bord_c+1);
	}
	
	my @bord_text_c = GetElements("${Theme}.${noml_HeadLines}.${noml_bordertextcolor}", %Config);
	my $cur_btext_c = 0;
	if( ($loc_max >= $loc_num) & ($#bord_text_c > -1) ) {
		my $diffo = $loc_max - $loc_num;
		$cur_btext_c = $diffo%($#bord_text_c+1);
	}
		
	print "<table ";
	if($bord_w) {
		print " bgcolor=\"$bord_c[$cur_bord_c]\" CELLSPACING=\"0\" CELLPADDING=";
		my $cel_pad = $bord_w - 1;
		print "\"$cel_pad\" ";
		my $temp_w = GetElement("${Theme}.${noml_HeadLines}.width", %Config);
		print "WIDTH=\"$temp_w\"  BORDER=\"0\"";
	} else {
		foreach $tag (@Table_metas) {
			my $temp_t = GetElement("${Theme}.${noml_HeadLines}.${tag}", %Config);
			if($temp_t) {
				print " $tag=\"$temp_t\" \n";
			}
		}
	}
	
	print " >\n\n";
	print "<tr ";
	foreach $tag (@TR_metas) {
		my $temp = GetElement("${Theme}.${noml_HeadLines}.${noml_TR}.${tag}", %Config);
		if($temp) {
			print " $tag=\"$temp\" \n";
		}
	}
	print " >";
	print "<td ";
	foreach $tag (@TD_metas) {
		my $temp = GetElement("${Theme}.${noml_HeadLines}.${noml_TD}.${tag}", %Config);
		if($temp) {
		print " $tag=\"$temp\" \n";
		}
	}
	print " >\n\n";
	
	
	# defaults to everyone is allowed to post if nothing there
	
	#temp- to do later
	print "<font ";
	if($fontface) {
		print "face=\"$fontface\" ";
	}
	if($#bord_text_c > -1) {
		print "color=\"$bord_text_c[$cur_btext_c]\" ";
	}
	print ">\n";
	
	print "<div align=center>";
	
	# Replies
	if($replies) {
		print " $text_replies${replies} | ";
	}
	
	# Post New
	print "<a ";
	if($CSS_Src) {
		print "class=\"$CSS_BorderLink\" ";
	}
	print "href=\"${location_nonews}?$param_cmd=$param_new&$param_dir=$loc_dir&$param_num=$loc_num";
	if($co->param($param_conf_prefix)) {
		my $temp_pref = $co->param($param_conf_prefix);
		print "$param_conf_prefix=$temp_pref&";
	}
	print "\">$text_post_new</a>";

	print "</div></font></td></tr><tr><td>";
	
	if($replies) {
		my $post_c = GetElement("${Theme}.${noml_HeadLines}.${noml_post}.${noml_bgcolor}", %Config);
		print "<table ";
		if($post_c) {
			print " bgcolor=\"$post_c\" CELLSPACING=\"0\" CELLPADDING=2";
		} else {
			foreach $tag (@Table_metas) {
				my $temp_t = GetElement("${Theme}.${noml_HeadLines}.${tag}", %Config);
				if($temp_t) {
					print " $tag=\"$temp_t\" \n";
				}
			}
		}       	

		print " ><tr><td><table>\n\n";
	
		my $hlines = GetElement("${Theme}.${noml_HeadLines}.${noml_head}.${noml_lines}", %Config);
		my $blines = GetElement("${Theme}.${noml_HeadLines}.${noml_body}.${noml_lines}", %Config);
		my $lower_width = GetElement("${Theme}.${noml_HeadLines}.${noml_body}.${noml_width}", %Config);
		HeadLines("$loc_dir/$loc_num", $hlines, $blines, $lower_width);
			
		print "</table></td></tr></table>";
	}

	
	print "</table>\n";
	
}

########################
# Read_HeadLine : Read
# the headline specified
# by the CGI params
########################
sub Read_HeadLine {
	if( ($co->param($param_dir)) & ($co->param($param_num)) ) {
		my $loc_dir = $co->param($param_dir);
		my $loc_num = $co->param($param_num);
		my $loc_max = $co->param($param_max);
		
		my $fontface = GetElement("${Theme}.${noml_HeadLines}.${noml_fontface}", %Config);
	
		my $bord_w = GetElement("${Theme}.${noml_HeadLines}.${noml_borderw}", %Config);
		
		my @bord_c = GetElements("${Theme}.${noml_HeadLines}.${noml_borderc}", %Config);
		my $cur_bord_c = 0;
		if( ($loc_max >= $loc_num) & ($#bord_c > -1) ) {
			my $diffo = $loc_max - $loc_num;
			$cur_bord_c = $diffo%($#bord_c+1);
		}
		
		my @backg_c = GetElements("${Theme}.${noml_HeadLines}.${noml_bgcolor}", %Config);
		my $cur_backg_c = 0;
		if( ($loc_max >= $loc_num) & ($#backg_c > -1) ) {
			my $diffo = $loc_max - $loc_num;
			$cur_backg_c = $diffo%($#backg_c+1);
		}
		
		my @text_c = GetElements("${Theme}.${noml_HeadLines}.${noml_textcolor}", %Config);
		my $cur_text_c = 0;
		if( ($loc_max >= $loc_num) & ($#text_c > -1) ) {
			my $diffo = $loc_max - $loc_num;
			$cur_text_c = $diffo%($#text_c+1);
		}

		my @bord_text_c = GetElements("${Theme}.${noml_HeadLines}.${noml_bordertextcolor}", %Config);
		my $cur_btext_c = 0;
		if( ($loc_max >= $loc_num) & ($#bord_text_c > -1) ) {
			my $diffo = $loc_max - $loc_num;
			$cur_btext_c = $diffo%($#bord_text_c+1);
		}

		
		print "<table ";
		if($bord_w) {
			print " bgcolor=\"$bord_c[$cur_bord_c]\" CELLSPACING=\"0\" CELLPADDING=";
			my $cel_pad = $bord_w - 1;
			print "\"$cel_pad\" ";
			my $temp_w = GetElement("${Theme}.${noml_HeadLines}.width", %Config);
			print "WIDTH=\"$temp_w\"  BORDER=\"0\" ><TR><TD COLSPAN=2>\n";
	
			print "<table ";
			if($#backg_c > -1) {
				print " bgcolor=\"$backg_c[$cur_backg_c]\" ";
			}
			print "CELLSPACING=\"0\" CELLPADDING=\"$bord_w\" WIDTH=";
			print "\"100%\"  BORDER=\"0\"";
		} else {
			foreach $tag (@Table_metas) {
				my $temp_t = GetElement("${Theme}.${noml_HeadLines}.${tag}", %Config);
				if($temp_t) {
					print " $tag=\"$temp_t\" \n";
				}
			}
		}

		print " >\n\n";
		print "<tr ";
		foreach $tag (@TR_metas) {
			my $temp = GetElement("${Theme}.${noml_HeadLines}.${noml_TR}.${tag}", %Config);
			if($temp) {
				print " $tag=\"$temp\" \n";
			}
		}
		print " >";
		print "<td ";
		foreach $tag (@TD_metas) {
			my $temp = GetElement("${Theme}.${noml_HeadLines}.${noml_TD}.${tag}", %Config);
			if($temp) {
			print " $tag=\"$temp\" \n";
			}
		}
		print " >\n\n";
	
		my %indiv_conf = ParseXML("${Data_Dir}${loc_dir}/${loc_num}/nonews.dat");
		my $post_day = GetElement($noml_date, %indiv_conf);
		my $post_auth = GetElement($noml_author, %indiv_conf);
		my $post_topic = GetElement($noml_topic, %indiv_conf);
		my $post_title = GetElement($noml_title, %indiv_conf);
		my $replies = GetElement($noml_max, %indiv_conf);
		my @post_keys = GetElements($noml_keywords, %indiv_conf);
		my @user_owner = GetElements("${noml_owner}.${noml_user}", %indiv_conf);
		my @group_owner = GetElements("${noml_owner}.${noml_group}", %indiv_conf);
			
		#Topic Icon
		if($post_topic) {
			print "<a href=\"${location_nonews}?";
			if($co->param($param_conf_prefix)) {
				my $temp_pref = $co->param($param_conf_prefix);
				print "$param_conf_prefix=$temp_pref&";
			}
			print "$param_cmd=$param_search&$param_bytopic=$post_topic\">";
			print "\n<img src=\"${location_topics}$post_topic${extension_topic}\" border=0 align=left alt=\"Topic: $post_topic\"></a>";
		}
		
		#Title
		print "<font ";
		if($fontface) {
			print "face=\"$fontface\" ";
		}
		if($#text_c > -1) {
			print "color=\"$text_c[$cur_text_c]\" ";
		}
		print ">\n";
		if($post_title) {
			print "<font size=+2>";
			print "$post_title</font><br>\n";
		}
		
		#Posted by
		print "<small>by <a href=\"${location_nonews}?";
		if($co->param($param_conf_prefix)) {
			my $temp_pref = $co->param($param_conf_prefix);
			print "$param_conf_prefix=$temp_pref&";
		}
		print "$param_cmd=$param_info&$param_name=$post_auth\">$post_auth</a> on $post_day</small><br><br>\n";
		
		#segment of message relevent to this section
		
		#Load the index file
		if(open(SRC, "${Data_Dir}${loc_dir}/${loc_num}/src.index") ) {
			my @src = <SRC>;
			close SRC;
			foreach $s (@src) {
				print "$s\n";
		        }
		}
		
		# end the message section
		print "</font>\n";
		if($bord_w) {
			print "</td></tr></table>\n";
		} else {
			print "<br>";
		}
		print "<font ";
		if($fontface) {
			print "face=\"$fontface\" ";
		}
		if($#bord_text_c > -1) {
			print "color=\"$bord_text_c[$cur_btext_c]\" ";
		}
		print "><div align=center>";
		
		my $prev_num = $loc_num - 1;
		my $next_num = $loc_num + 1;
		if($prev_num > -1) {
			if(open(SRC, "${Data_Dir}${loc_dir}/${prev_num}/nonews.dat")) {
				my @src = <SRC>;
				close SRC;
				my %prev_conf = ParseXML_PreLoaded(@src);
				my $prev_day = GetElement($noml_date, %prev_conf);
				my $prev_auth = GetElement($noml_author, %prev_conf);
				my $prev_title = GetElement($noml_title, %prev_conf);
				print "&lt <a ";
				if($CSS_Src) {
					print "class=\"$CSS_BorderLink\" ";
				}
				print "href=\"${location_nonews}?";
				if($co->param($param_conf_prefix)) {
					my $temp_pref = $co->param($param_conf_prefix);
					print "$param_conf_prefix=$temp_pref&";
				}
				print "$param_cmd=$param_read&$param_dir=$loc_dir&$param_num=$prev_num";
				if($loc_max) {
					print "&$param_max=$loc_max";
				}
				print "\">";
				print "$prev_title (<small>$prev_auth, $prev_day</small>)</a> |\n";
			}
		}
		if(open(SRC, "${Data_Dir}${loc_dir}/${next_num}/nonews.dat")) {
			my @src = <SRC>;
			close SRC;
			my %next_conf = ParseXML_PreLoaded(@src);
			my $next_day = GetElement($noml_date, %next_conf);
			my $next_auth = GetElement($noml_author, %next_conf);
			my $next_title = GetElement($noml_title, %next_conf);
			print "| <a ";
			if($CSS_Src) {
				print "class=\"$CSS_BorderLink\" ";
			}
			print "href=\"${location_nonews}?";
			if($co->param($param_conf_prefix)) {
				my $temp_pref = $co->param($param_conf_prefix);
				print "$param_conf_prefix=$temp_pref&";
			}
			print "$param_cmd=$param_read&$param_dir=$loc_dir&$param_num=$next_num";
			if($loc_max) {
				print "&$param_max=$loc_max";
			}
			print "\">";
			print "$next_title (<small>$next_auth, $next_day</small>)</a> &gt\n";
		}

		print "</div></font></td></tr></table>\n\n";
		
		print "<br><br><!------ BEGIN POST SECTION -------------->\n\n";
		
		PostHeader($replies, @user_owner, @group_owner);
		
		#print "<br>";
		
		#if($replies) {
		#}
		print "<!---------- END POST SECTION -------------->\n\n";

	} else {
		# output some sort of error
		print "err";
	}
}

1;