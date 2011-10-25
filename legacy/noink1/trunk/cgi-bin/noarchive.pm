#noarchive.pm
#------------
#routines for dealing with archives (because I didn't plan ahead in nolib.pm, and am now too lazy to go back and fix it, doh!)
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

########################
# GetNextPrev - Given
# the curdir and the
# searchdir, will get
# next previous items in
# *NOI file
########################
sub GetNextPrev {
	my ($curdir, $searchdir) = @_;
	my $temp = "";
	my $prevdir = "";
	my $nextdir = "";
	undef $prevdir;
	undef $nextdir;

	#First, let's get all the <location> fields in the index.noi file in $searchdir
	my @locations = ("");
	$#locations = -1;
	
	open(NOIFILE, "$archive_root{$root}$searchdir${index_file}");
	my @noifile = <NOIFILE>;
	close NOIFILE;
	
	foreach $temp (@noifile) {
		#Strip off extra spaces
		$temp =~ s/^\s+//;
		$temp =~ s/\s+$//;
		#Strip off extra newlines
		$temp =~ s/^\n+//;
		$temp =~ s/\n+$//;
		#Strip off extra tabs
		$temp =~ s/^\t+//;
		$temp =~ s/\t+$//;
		my %check = split(/$conf_split/,$temp);
		if ($check{$conf_loc}) {
			push(@locations, $check{$conf_loc});
		}
	}
	
	#Now we search and compare those locations with our current one to get the next and previous ones
	
	for ($i=0; $i<=$#locations; $i++) {
		if($locations[$i] eq $curdir) {
			if($i > 0) {
				$prevdir = $locations[$i-1];
			}
			if($i < $#locations) {
				$nextdir = $locations[$i+1];
			}
			last;
		}
	}
	
	return ($nextdir, $prevdir, $locations[0], $locations[$#locations]);

}

########################
# ArchiveNextPrev -
# Displays the next/prev
# buttons when perusing
# an archive
########################
sub ArchiveNextPrev {
	my ($curdir, $searchdir) = @_;
	
	foreach ($curdir, $searchdir) {
		#Strip off extra spaces
		s/^\s+//;
		s/\s+$//;
		#Strip off extra newlines
		s/^\n+//;
		s/\n+$//;
		#Strip off extra tabs
		s/^\t+//;
		s/\t+$//;
	}
	
	undef $prevdir;
	undef $nextdir;
	my $firstitem = "";
	my $lastitem = "";
		
	($nextdir, $prevdir, $firstitem, $lastitem) = GetNextPrev($curdir, $searchdir);
	my $searchdirnext = $searchdir;
	my $searchdirprev = $searchdir;
	if(! defined $nextdir) {
		#Try same level, last item on previous entry
		my @tempsearch = split(/$dir_sep/, $searchdir);
		my $newcurdir = pop(@tempsearch);
		
		$newcurdir = "$newcurdir${dir_sep}";
		
		my $newsearchdir = join("$dir_sep", @tempsearch);
		if($newsearchdir != "") {
			$newsearchdir = "$newsearchdir${dir_sep}";
		}
		
		#Go back one directory, and get next directory
		($newnext, $newprev, $newfirst, $newlast) = GetNextPrev($newcurdir, $newsearchdir);
		
		$newsearchdir = "$newsearchdir${newnext}";
		#Now, let's get the first one in that directory and use it
		($newnext2, $newprev2, $newfirst2, $newlast2) = GetNextPrev($newcurdir, $newsearchdir);
		
		if($newfirst2 != "") {
			$searchdirnext = $newsearchdir;
			$nextdir = $newfirst2;
		} else {
			#Okay, we need to move up one level
			$newsearchdir = join("$dir_sep", @tempsearch);
			if($newsearchdir != "") {
				$newsearchdir = "$newsearchdir${dir_sep}";
			}
			#print "newsearchdir = \"$newsearchdir\" --- newcurdir = \"$newcurdir\"<br>\n";
			#Go back one directory, and get next directory
			($newnext, $newprev, $newfirst, $newlast) = GetNextPrev($newcurdir, $newsearchdir);
			#print "next = \"$newnext\" -- prev = \"$newprev\" -- first = \"$newfirst\" -- last = \"$newlast\"<br>\n";
			if(defined $newnext) {
				$searchdirnext = $newsearchdir;
				$nextdir = $newnext;
			} else {
				#we only get here if we are dealing with year spanning!
				$newcurdir = $newsearchdir;
				$newsearchdir = "";
				#print "newsearchdir = \"$newsearchdir\" --- newcurdir = \"$newcurdir\"<br>\n";

				($newnext, $newprev, $newfirst, $newlast) = GetNextPrev($newcurdir, $newsearchdir);
				#print "next = \"$newnext\" -- prev = \"$newprev\" -- first = \"$newfirst\" -- last = \"$newlast\"<br>\n";
				if(defined $newnext) {
					$searchdirnext = $newsearchdir;
					$nextdir = $newnext;
				}
				# Note that I would prefer to go back down into the same sublevel that they were before!
				#I.e, if they were on a day-to-day listing, when it leaps over to a new year, it'd be nice
				#to go to the first day of that year.. However, that would be a royal pain, and I don't
				#feel like doing that now.... it certainly isn't something blocking version 1.0.0, so
				#screw it... I'll leave it this way and fix it in the future if I find this unwieldy...
			}
		}
		
	}
	
	#print "prevdir $prevdir<br>\n";
	
	if(! defined $prevdir) {
		#Try same level, last item on previous entry
		my @tempsearch = split(/$dir_sep/, $searchdir);
		my $newcurdir = pop(@tempsearch);
		
		$newcurdir = "$newcurdir${dir_sep}";
		
		my $newsearchdir = join("$dir_sep", @tempsearch);
		if($newsearchdir != "") {
			$newsearchdir = "$newsearchdir${dir_sep}";
		}
		
		#Go back one directory, and get next directory
		($newnext, $newprev, $newfirst, $newlast) = GetNextPrev($newcurdir, $newsearchdir);
		
		$newsearchdir = "$newsearchdir${newprev}";
		
		#Now, let's get the first one in that directory and use it
		($newnext2, $newprev2, $newfirst2, $newlast2) = GetNextPrev($newcurdir, $newsearchdir);
		
		if($newlast2 != "") {
			$searchdirprev = $newsearchdir;
			$prevdir = $newlast2;
		} else {
			#Okay, we need to move up one level
			$newsearchdir = join("$dir_sep", @tempsearch);
			if($newsearchdir != "") {
				$newsearchdir = "$newsearchdir${dir_sep}";
			}
			#Go back one directory, and get next directory
			($newnext, $newprev, $newfirst, $newlast) = GetNextPrev($newcurdir, $newsearchdir);
			if(defined $newprev) {
				$searchdirprev = $newsearchdir;
				$prevdir = $newprev;
			} else {
				#we only get here if we are dealing with year spanning!
				$newcurdir = $newsearchdir;
				$newsearchdir = "";

				($newnext, $newprev, $newfirst, $newlast) = GetNextPrev($newcurdir, $newsearchdir);
				if(defined $newprev) {
					$searchdirprev = $newsearchdir;
					$prevdir = $newprev;
				}
				# Note that I would prefer to go back down into the same sublevel that they were before!
				#I.e, if they were on a day-to-day listing, when it leaps over to a new year, it'd be nice
				#to go to the first day of that year.. However, that would be a royal pain, and I don't
				#feel like doing that now.... it certainly isn't something blocking version 1.0.0, so
				#screw it... I'll leave it this way and fix it in the future if I find this unwieldy...
			}
		}
		
	}
	
	if(defined $prevdir) {
		print "[ <a href=\"$noink_cgi?${option_root}=$root&$option_index_dir=$option_index_archive&$option_dir=$searchdirprev$prevdir\">$msg_archive_previous{$root}</a> ] ";
	} else {
		#we default at the root of the archive
		print "[ <a href=\"$noink_cgi?${option_root}=$root&$option_index_dir=$option_index_archive\">$msg_archive_previous{$root}</a> ] ";
	}
	
	if(defined $nextdir) {
		print "[ <a href=\"$noink_cgi?${option_root}=$root&$option_index_dir=$option_index_archive&$option_dir=$searchdirnext$nextdir\">$msg_archive_next{$root}</a> ] ";
	} else {
		#We default ot going back to the main screen!
		print "[ <a href=\"$noink_cgi?${option_root}=$root\">$msg_archive_next{$root}</a> ] ";
	}
}

#######################
# ArchiveWhereAmI -
# Displays where we are
# in the archive list
#######################
sub ArchiveWhereAmI {
	my (@dirlist) = @_;
	#Just because I'm paranoid! ;)
	if($#dirlist >= 0) {
		print "\n<table width=\"100%\" cols=1 border=0 cellpadding=2 cellspacing=2 nosave>\n";
		print "<tr valign=center>\n";
		print "<td align=left>\n";
		#Read in the NOI file
		my @upone = @dirlist;
		my $curdir = pop(@upone);
		
		if($#dirlist >= 3) {
			my $tempdir = pop(@upone);
			#$curdir = "$tempdir${dir_sep}$curdir";
		}
		
		$prevdir = join("$dir_sep", @upone);
		
		open(NOIFILE, "$archive_root{$root}$prevdir${dir_sep}${index_file}");
		my @noifile = <NOIFILE>;
		close NOIFILE;
		
		my @locations = ();
		my @subs = ();
		$#subs = -1;
		$#locations = -1;
		
		#This is assumed to be using Noink generated archive NOI files!
		# Normal files (generated by the user) will likely not work!
               	foreach $temp (@noifile) {
			#Strip off extra spaces
			$temp =~ s/^\s+//;
			$temp =~ s/\s+$//;
			#Strip off extra newlines
			$temp =~ s/^\n+//;
			$temp =~ s/\n+$//;
			#Strip off extra tabs
			$temp =~ s/^\t+//;
			$temp =~ s/\t+$//;
		
			my %check = split(/$conf_split/,$temp);
			if ($check{$conf_desc}) {
				push(@locations, $check{$conf_desc});
		
			} elsif ($check{$conf_sub}) {
				push(@subs, $check{$conf_sub});
		
			}
		}
		
		for ($i=0; $i<=$#subs; $i++) {
			if($subs[$i] eq $curdir) {
				print "<i>$locations[$i]</i>";
				last;
			}
		}
		print "</td></tr></table>\n";
	}
}

#######################
# ArchiveList -
# Lists the current
# archive depth
#######################
sub ArchiveList {
	if ($option{$option_index_dir} eq $option_index_archive) {
		my $workdir = $option{$option_dir};
		#print "$workdir<br>\n";
		my @dirlist = split(/$dir_sep/, $workdir);
		ArchiveWhereAmI(@dirlist);
		if($#dirlist > -1) {
			print "\n<table width=\"100%\" cols=2 border=0 cellpadding=2 cellspacing=2 nosave>\n";
			print "<tr valign=center>\n";
			print "<td align=left>\n";
			print "[ <a href=\"$noink_cgi?${option_root}=$root&$option_index_dir=$option_index_archive\">$msg_archive_main{$root}</a> ]";
			if($#dirlist > 0) {
				print " [ <a href=\"$noink_cgi?${option_root}=$root&$option_index_dir=$option_index_archive&$option_dir=$dirlist[0]$dir_sep\">$dirlist[0]</a> ]";
				if($#dirlist > 1) {
					print " [ <a href=\"$noink_cgi?${option_root}=$root&$option_index_dir=$option_index_archive&$option_dir=$dirlist[0]$dir_sep${dirlist[1]}$dir_sep\">$dirlist[1]</a> ]";
				}
			}
			print "\n</td><td align=right>\n";
			if($#dirlist == 1) {
				#Next/Prev will be using Month hiearchy
				ArchiveNextPrev("$dirlist[1]${dir_sep}", "$dirlist[0]${dir_sep}");
			} elsif($#dirlist >= 2) {
				#Next/Prev will be using Day hiearchy
				ArchiveNextPrev("$dirlist[2]${dir_sep}$dirlist[3]${dir_sep}", "$dirlist[0]${dir_sep}$dirlist[1]${dir_sep}");
			} else {
				#Default to Year hiearchy
				ArchiveNextPrev("$dirlist[0]${dir_sep}", "");
			}
			
			print "</td></tr></table>\n";
		}
	}
}

#######################
# ArchiveNoiUpdate -
# update or create the
# appropriate index.noi
# files
#######################
sub ArchiveNoiUpdate {
	my ($year, $month, $day, $dstamp, $dindex) = @_;
	my @index_contents;
	#Start with root
	ArchiveNoiCheck( "$archive_root{$root}$index_file", "$conf_loc${conf_split}$year${dir_sep}", $year, "$msg_pre_year{$root} $year $msg_post_year{$root}");
	#Now do year
	ArchiveNoiCheck( "$archive_root{$root}$year${dir_sep}$index_file", "$conf_loc${conf_split}$month${dir_sep}", $month, "$msg_pre_month{$root} $month $msg_post_month{$root}");
	#Next do month
	ArchiveNoiCheck( "$archive_root{$root}$year${dir_sep}$month${dir_sep}$index_file", "$conf_loc${conf_split}$day${dir_sep}$dstamp${dir_sep}", $dstamp, "$msg_pre_day{$root} $dindex $msg_post_day{$root}");	
}

########################
# ArchiveNoiCheck - This
# does the actual
# checking and updating
# of the .noi file...
#######################
sub ArchiveNoiCheck {
	my ($loc_index, $line_needed, $subguy, $my_msg) = @_;
	my $sub_exists = $no;
	#print "$loc_index<br>";
	if(open(ROOTBY, "$loc_index")) {
		@index_contents = <ROOTBY>;
		close ROOTBY;
		foreach $s (@index_contents) {
			if($s =~ /$line_needed/) {
				$sub_exists = $yes;
			}
		}
	}
	#print "$sub_exists<br>";
	if($sub_exists eq $no) {
		#print "inside, openning $loc_index<br>";
		open(ROOTBY, ">>$loc_index");
		print ROOTBY "$conf_head\n";
		print ROOTBY "\t$conf_sub${conf_split}$subguy\n";
		print ROOTBY "\t$line_needed\n";
		print ROOTBY "\t$conf_desc${conf_split}$my_msg\n";
		print ROOTBY "$conf_head${conf_end}\n\n";
		close ROOTBY;
	}
}

#######################
# ArchiveMain: The main
# archive interface
#######################
sub ArchiveMain {
	if($groups[$user_id] !~ /admin/) {
		print "$msg_sorry_adminonly{$root}<br>";
	} else {
		#my $dstamp = "";
		#my $dindex = "";
		my $msgwas = "";
		#First, let's see if we've been here before...
		if($posted{$form_archive} eq $yes) {
			#okay, we can go ahead and archive the whole site
			print "$msg_archive_working{$root}<br><br>";
			my $year = `$date_options_year`;
			my $month = `$date_options_month`;
			my $day = `$date_options_daynum`;
			foreach ($year, $month, $day) {
				s/^\s+//;
				s/\s+$//;
			}
			mkdir "$archive_root{$root}$year", 0755;
			mkdir "$archive_root{$root}$year${dir_sep}$month", 0755;
			mkdir "$archive_root{$root}$year${dir_sep}$month${dir_sep}$day${dir_sep}", 0755;
			#print "$copy_rec_f $data_root{$root} $archive_root{$root}$year${dir_sep}$month${dir_sep}$day${dir_sep}$posted{$form_archive_dstamp}${dir_sep}<br>";
			$msgwas = `$copy_rec_f $data_root{$root} $archive_root{$root}$year${dir_sep}$month${dir_sep}$day${dir_sep}$posted{$form_archive_dstamp}${dir_sep}`;
			
			print "<br>$msgwas<br>\n\n";
			
			#Create/update the index.noi files
			ArchiveNoiUpdate($year, $month, $day, $posted{$form_archive_dstamp}, $posted{$form_archive_dindex});
			
			print "<a href=\"$noink_cgi?${option_root}=$root\">$msg_archive_done{$root}</a><br><br>";
		} elsif($posted{$form_archive} eq $no) {
			print "<a href=\"$noink_cgi?${option_root}=$root\">$msg_archive_cancel{$root}</a><br>";
		} else {
			#give them the options to back out if necessary
			print "<table width=\"100%\" cols=2 border=0 cellpadding=\"5\" cellspacing=\"10%\" nosave>\n";
			print "<tr><td align=left bgcolor=$AdminBGColor{$root}><font size=+1 face=arial,helvetica><b>${blank_space}$msg_archive_dialog{$root}</b></font></td><br>\n";
			print "</td></tr><td align=left>";
			print "$msg_archive_instruct{$root}<br><br>\n";
			print "<table width=\"90%\" cols=2 border=0 cellpadding=\"10\" cellspacing=\"10%\" nosave>";
			print "<tr><td align=left valign=top bgcolor=$AdminBGLight{$root}><ul>\n";
			print "<br><form method=\"post\" action=\"$noink_cgi?${option_root}=$root&$cmd=$cmd_archive\" enctype=\"application/x-www-form-urlencoded\">\n";
			$dstamp = `$date_archive_stamp`;
			$dindex = `$date_archive_index`;
			foreach ($dstamp, $dindex) {
				s/^\s+//;
				s/\s+$//;
			}
			print "<input type=\"hidden\" name=\"$form_archive_dstamp\" value=\"$dstamp\">";
			print "<input type=\"hidden\" name=\"$form_archive_dindex\" value=\"$dindex\">";
			print "$msg_archive_dstamp{$root} \"$dstamp\"<br><br>$msg_archive_dindex{$root} \"$dindex\"<br><br>";
			print "<blockquote><b>$msg_archive_certain{$root}</b><br>\n";
			print "<select name=\"$form_archive\">\n";
			print "<option value=\"$yes\">$yes\n";
			print "<option value=\"$no\">$no\n";
			print "</select>$blank_space$blank_space$blank_space<input type=submit value=\"Submit\">";
			print "</blockquote></form>";
			print "</td></tr></table></td></tr></table>";
		}
	}
}

1;