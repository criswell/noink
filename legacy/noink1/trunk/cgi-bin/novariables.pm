# novariables.pm
# --------------
# System-wdie variables (only monkey with if necessary)
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

#################################################
# User defined variables for internationalization
#################################################

# Days of the week
#-----------------
	$day[0] = "Sunday";
	$day[1] = "Monday";
	$day[2] = "Tuesday";
	$day[2] = "Wednesday";
	$day[3] = "Thursday";
	$day[4] = "Friday";
	
# Months of the year
#-------------------
	$month[0] = "Jan";
	$month[1] = "Feb";
	$month[2] = "Mar";
	$month[3] = "Apr";
	$month[4] = "May";
	$month[5] = "Jun";
	$month[6] = "Jul";
	$month[7] = "Aug";
	$month[8] = "Sep";
	$month[9] = "Oct";
	$month[10]= "Nov";
	$month[11]= "Dec";

#############################################################################
# System defined variables (do not modify unless you know what you are doing)
#############################################################################

# System commands
#----------------

	# URL Options
	$cmd = 'cmd';
	$cmd_admin = 'admin';
	$cmd_forum = 'forum';
	$cmd_login = 'login';
	$cmd_newuser = 'newuser';
	$cmd_userconfig = 'userconfig';
	$cmd_updateuser = 'updateuser';
	$cmd_remind = 'remind';
	$cmd_usermanage = 'usermanage';
	$cmd_lockadmin = 'lockadmin';
	$cmd_deleteuser = 'deleteuser';
	$cmd_update = 'update';
	$cmd_archive = 'archive';
	$cmd_copylong = 'copyright';
	$cmd_pre = 'pre';
	$cmd_post = 'post';
	$cmd_updateSection = 'updatesect';
	#$cmd_newmsg = 'newmsg';
	#$cmd_replymsg = 'replymsg';
	#$cmd_sortbydate = 'sortbydate';
	#$cmd_sortbytitle = 'sortbytitle';
	#$cmd_sortbyname = 'sortbyname';
		
	$option_root = 'root';
	$option_dir = 'dir';
	$option_uid = 'uid';
	$option_msg = 'msg';
	$option_subforum = 'subfor';
	$option_sub = 'sub';
	$option_section = 'section';
	
	#For extra directories (such as archives) we do this
	#the reason for the abstraction is that it would be bad
	#to simply pass the actuall directory here for 2 reasons:
	# 1- It would tell other users explicitly where the data was
	# 2- It would allow for other users to redirect the input to
	#    their directory (when the other user wasn't you ;)
	# For the 1.0.x version numbers, this will have little function
	# other than for archiving... but I do have some further plans
	# for it in the 1.2.x branch
	$option_index_dir = 'indy';
	$option_index_archive = 'archy';
	
	# Forum Options
	$forum_cmd = 'forum';
	$forum_new = 'new';
	$forum_reply = 'reply';
	$forum_post = 'post';
	$forum_addpost = 'addpost';
	$forum_more = 'more';
	$forum_delthread = 'delete';
	$forum_clear = 'clear';
	
	# Form options
	$form_username = "username";
	$form_password = "password";
	$form_groups = "groups";
	$form_update_username = "username_up";
	$form_update_password = "password_up";
	$form_update_groups = "groups";
	$form_password_verify = "password2";
	$form_hidden_id = "hidid";
	$form_hidden_date = "hidda";
	$form_hidden_msgnum = "hidmnum";
	$form_hidden_submsg = "hidsubm";
	$form_title = "title";
	$form_content = "content";
	$form_archive = "archive";
	$form_archive_dstamp = "stamp";
	$form_archive_dindex = "index";
	#$form_ascend = 'Ascend';
	#$form_descend = 'Descend';
	
	# Cookie options
	$hidden_username = "HU"; #These are a bit cryptic, forgive me... vain attempt at some sort of security
	$hidden_password = "HP";
	$hidden_password_key = "HK";
	
# System constants (that aren't really constants)
#------------------------------------------------

	# Items largely for non-languages specifics
	$right = "right";
	$left = "left";
	$top = "top";
	$yes = "yes";
	$no = "no";
	
	# Maximum recursive depth for HTML include
	$max_recinc_deep = 5;
	
	# The guest account defaults to 1, though you could change that, if you /REALLY/ wanted
	$guest_user = 1;
	
	#Maximum number of encryption keys per user
	$max_keys = 5;
	#Chances of making a whole new encryption key,
	#set lower if you want new encryption keys made all the time (minimum of 1, or 50% of the time)
	#set higher if you're fine with keeping old ones around for a while
	$key_chance = 1000; # 1 out of $key_chance times we will make a new key (round-abouts ;)
	
	#Characters we are to worry about in the password (anything not covered here doesn't get translated :P )
	$password_chars_source = '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
	@password_chars = split(//, $password_chars_source); #array to be used
	
	#It is prefereable to have a smaller segment of characters to be used in remind passwords
	$remind_chars_source = '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
	@remind_chars = split(//, $remind_chars_source);

	#Number of jumbling iterations (maximum and minimum)
	$max_num_iterations = $#password_chars * 3;
	$min_num_iterations = 4;
	
	$extra_link = "link";
	$extra_url = "url";
	$extra_email = "email";
	$extra_image = "image";
	$extra_other = "other";
	$extra_blank = "extra";
			
# System file allocations
#------------------------

	$accounts = "accounts/";
	$passwd_file = "${accounts}Passwd.dat";
	$key_file = "key";
	$index_file = "index.noi";
	$forum_file = "forum.noi";
	$forum_posts = "forum/";
	$post_num = "MAXPOSTS.dat";
	$copyright_years_file = "COPYRIGHTS.dat";
	$alt_config_file = "no.conf"; #For alternative configurations to those in noconf.pm

# System Configuration File Commands
#-----------------------------------

	$conf_end = "<end>"; #end of section
	$conf_null = "<NULL>";
	$conf_sub = "<sub>";
	$conf_split = "="; #Change this if and only if you need to use another character as split value in the config file!!!!
	$conf_permissions = "<permissions>";
	$conf_owner = "<owner>";
	$conf_group = "<group>";
	$conf_cols = "<columns>";
	$conf_default_cols = 4;
	$conf_space = ' ';
	
	#Sections:
	$conf_head = "<head>";
	$conf_content = "<content>";
	@conf_sections = ($conf_head, $conf_content);
	
	#Generic sub-types:
	$conf_name = "<name>";
	$conf_loc = "<location>";
	$conf_desc = "<description>";
	$conf_img = "<image>";
	$conf_url = "<url>";
	$conf_forum = "<forum>";
	$conf_link = "<link>";
	$conf_nolink = "<nolink>";
	$conf_include = "<include>";
	$conf_include_rel = "<relative>";
	
	#Forum Config File Commands
	$forum_conf = "<configuration>";
	
	#Forum Head commands
	#-Use same as generic subtypes, above
	
	#Forum Conf section commands
	$forum_noguest = "<no guest>"; #for when we don't want guests posting (i.e., no anonymouse posts)
	$forum_moderator = "<moderator>"; #will contain moderator's e-mail
	$forum_deep = "<deep>"; #for showing, <deep>=X, X deep posts on main screen (indiv posts will be unlimited)
	$forum_ascending = "<ascend>";
	$forum_descending = "<descend>";
	#usage for these next few commands are as such (for sorting)
	# <by date>=<ascend> - sort by date, ascending
	# etc.
	#$forum_bydate = "<by date>";
	#$forum_bytitle = "<by title>";
	#$forum_byname = "<by name>";
	
	#Time replacement commands
	$insert_year = "<year>";
	$insert_cyear = "<copyright-years>"; #Place <copyright-years> in your Copyright HTML files and Noink will add all included years to copyright
	$insert_time = "<time>";
	$insert_full_date = "<fulldate>";
	
	#Included file specific directives
	$incdir_fspace = "<force space>";
	
	$fspace = "&nbsp;";
	
	#####################################################################################
	#noml items - These will replace the previous definitions by 2.X
	$noml_pre_bracket = '<';
	$noml_start = '<?noml';
	$noml_version = 'version';
	$noml_include = 'include';
	$version_noml_default = '0.x';
	
        # NoML Privalege items
        $noml_owner = 'owner';
        $noml_group = 'group';
        $noml_permissions = 'permissions';

        # NoML Layout items
        $noml_layout = 'layout';
        $noml_section = 'section';
        $noml_layoutcmd_borderstart = 'borderstart';
        $noml_layoutcmd_borderend = 'borderend';
        $noml_layoutcmd_newline = 'newline';


	
 # Post File Sections
 #-------------------

 	$post_title = "<title>";
 	$post_from = "<from>";
 	$post_date = "<date>";
 	$post_ip = "<ip>";
 	$post_content = "<content>";
 	