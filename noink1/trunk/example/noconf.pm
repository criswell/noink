# noconf.pm

#########################################
# Root site declarations:
#----------------------------------------
# This is where you place any and all
# the sites noink is to cover (to be
# used in hashes later). All you need
# to worry about here is giving each
# site its own unique and simple (single-
# word) name. (This will be used largely
# internally by noink... the user will
# not see these, except in the URL query
# or if they are an admin).
# NOTE: that the first element in this
# array ($root_sites[0]) is the default
# site. If you are only using noink for
# one site, then simply leave this alone.
#########################################

@root_sites = ("default", "testb", "main", "noink", "tuxtype");

################# DEFAULT SITE SPECIFICS ##########################

#########################################
# Site specifications:
#----------------------------------------
# These are for various title, default
# colors, and metatag items for each site
#########################################

$title{$root_sites[0]} = "Testing Site A";
$URL{$root_sites[0]} = "http://www.geekcomix.com/noink/testa/";
$classification{$root_sites[0]} = "Noink Example";
$description{$root_sites[0]} = "Noink Example";
$keywords{$root_sites[0]} = "linux, perl, noink, cgi, images, content, gnu, free, software, web";
$rating{$root_sites[0]} = "none";
$copyright{$root_sites[0]} = "Copyright (c) 2000 Sam Hart";
$author{$root_sites[0]} = "Sam Hart";
$replyto{$root_sites[0]} = "hart\@geekcomix.com";
$language{$root_sites[0]} = "English";
$section_sep{$root_sites[0]} = "<br><hr size=2 width=\"100%\">";

$RearColor{$root_sites[0]} = "5F9EA0";
$PlainText{$root_sites[0]} = "000000";
$Vlink{$root_sites[0]} = "8B0000";
$link{$root_sites[0]} = "8B008B";
$BGColor{$root_sites[0]} = "B0E2FF";
$HeadBGColor{$root_sites[0]} = "778899";
$AdminBGColor{$root_sites[0]} = "33CC00";
$AdminBGLight{$root_sites[0]} = "33CC88";

$main_width{$root_sites[0]} = "70%";

$topbar_w{$root_sites[0]} = "100%";
$topbar_border{$root_sites[0]} = "0";
$topbar_padding{$root_sites[0]} = "5";
$topbar_spacing{$root_sites[0]} = "5";

$logo_width{$root_sites[0]} = "40%";

$page_width{$root_sites[0]} = "100%";
$page_border{$root_sites[0]} = "0";
$page_padding{$root_sites[0]} = "4";
$page_spacing{$root_sites[0]} = "0";

$leftbar_w{$root_sites[0]} = "10%";

$loginbox_w{$root_sites[0]} = "25%";

$min_password_size{$root_sites[0]} = 2;

$remindpassword_size{$root_sites[0]} = 5;

############################
# Forum Specifics:
#---------------------------
# Various form defaults and
# other configurations.
############################

$default_forum_depth{$root_sites[0]} = 3;
$default_forum_perscreen{$root_sites[0]} = 5;
$forum_max_inner{$root_sites[0]} = 5;
$forum_maxlength{$root_sites[0]} = 100; #lines or newlines

$forum_header_BGColor{$root_sites[0]} = "0090FF";
$forum_post_BGColor{$root_sites[0]} = "AAFFFF";

$forum_reply_pre{$root_sites[0]} = "RE: ";

################################
# Archive Specifics:
#-------------------------------
# Exactly what are our archiving
# policies?
################################

$can_archive{$root_sites[0]} = $yes;

###############################
# File Specifics:
#------------------------------
# What and where noink is to
# look for things
###############################

$leftbar_file{$root_sites[0]} = "/home/geekcomix/www/noink/testa/leftbar.html";
$rightbar_file{$root_sites[0]} = "/home/geekcomix/www/noink/testa/rightbar.html";
$topbar_file{$root_sites[0]}= "/home/geekcomix/www/noink/testa/topbar.html";
$data_root{$root_sites[0]} = "/home/geekcomix/www/noink/testa/data/";
$admin_root{$root_sites[0]} = "/home/geekcomix/www/noink/testa/admin/";
$archive_root{$root_sites[0]} = "/home/geekcomix/www/noink/testa/archives/";
$site_archive_root{$root_sites[0]} = "/noink/testa/archives/";
$site_root{$root_sites[0]} = "/noink/testa/data/";

###############################
# Contact Specifics:
#------------------------------
# Who to contact and what pages
# for additional reference.
###############################

$mail_admin{$root_sites[0]} = "hart\@geekcomix.com";

###############################
# Message Specifics:
#------------------------------
# What messages and output
# noink is supposed to use
###############################

$msg_nodata{$root_sites[0]} = "No data available! Please contact administrator as <a href=\"mailto:$mail_admin{$root_sites[0]}\">$mail_admin{$root_sites[0]}</a>!";
$msg_forum{$root_sites[0]} = "Click here for the forum...";
$msg_loginbar{$root_sites[0]} = "User Login";
$msg_adminbar{$root_sites[0]} = " Administration";
$msg_welcome{$root_sites[0]} = "Welcome";
$msg_crack{$root_sites[0]} = "You are a suspected cracker";
$msg_username{$root_sites[0]} = "Input Username:";
$msg_password{$root_sites[0]} = "Input Password:";
$msg_newuser{$root_sites[0]} = "Or click here you create an account if a new user...";
$msg_userconfig{$root_sites[0]} = "Click here to configure your account";
$msg_adminconfig{$root_sites[0]} = "Click here to administer this site";
$msg_featuresorry{$root_sites[0]} = "<b>Sorry, this feature is not yet implimented....</b>";
$msg_add_user_sorry{$root_sites[0]} = "<b>To obtain an account on this site please contact <a href=\"mailto:$mail_admin{$root_sites[0]}\">$mail_admin{$root_sites[0]}</a>!";
$msg_newuserdialog{$root_sites[0]} = "New User Dialog";
$msg_newuser_instruct{$root_sites[0]} = "Welcome,<br>To obtain an account on this web-site, please fill out the following form in its entirety.";
$msg_newuser_username{$root_sites[0]} = "Please enter a User Name:";
$msg_newuser_password1{$root_sites[0]} = "Please enter a password:";
$msg_newuser_password2{$root_sites[0]} = "Please enter your password again:";
$msg_newuserdialog_error{$root_sites[0]} = "Error!";
$msg_newuser_errors_instruct{$root_sites[0]} = "There were problems with your form. Those problems were:";
$msg_newuser_nametaken{$root_sites[0]} = "The name you chose has already be taken.";
$msg_newuser_passdontmatch{$root_sites[0]} = "The passwords you supplied did not match.";
$msg_newuser_passtoosmall{$root_sites[0]} = "The password you supplied was too small.";
$msg_newuser_success{$root_sites[0]} = "Your account has been created! Click <a href=\"http://www.geekcomix.com/noink/testa/\">here</a> to return to main screen...";
$msg_email_remind{$root_sites[0]} = "Forgotten your password? Click here....";
$msg_passremind_subject{$root_sites[0]} = "Password Remind";
$msg_passremind_head{$root_sites[0]} = "Your password is: ";
$msg_passremind_foot{$root_sites[0]} = "\n\nPlease change it as soon as you logon!\n\n\cD";
$msg_password_sent{$root_sites[0]} = "Your password has been sent...";
$msg_passremind_dialog{$root_sites[0]} = "Password Remind Dialog";
$msg_passremind_dialog_error{$root_sites[0]} = "Error!";
$msg_passremind_instruct{$root_sites[0]} = "Welcome,<br>To have your e-mail sent to you, please fill out your valid username...";
$msg_passremind_username{$root_sites[0]} = "Username";
$msg_passremind_errors_instruct{$root_sites[0]} = "There were problems with your request. Those problems were:";
$msg_passremind_nomatch{$root_sites[0]} = "There is no account with this username.";
$msg_passremind_emailprob{$root_sites[0]} = "The account you specified has problems with its e-mail... Please contact the administrator at <a href=\"mailto:$mail_admin{$root_sites[0]}\">$mail_admin{$root_sites[0]}</a>!";
$msg_passremind_badaccount{$root_sites[0]} = "The account you specified was not valid.";
$msg_already_logon{$root_sites[0]} = "Sorry... you appear to already be logged in...";
$msg_userupdate_success{$root_sites[0]} = "Your account has been updated! Click <a href=\"http://www.geekcomix.com/noink/testa/\">here</a> to return to main screen... (For security reasons, you may need to relogin!)";
$msg_userupdate{$root_sites[0]} = "User Configuration";
$msg_userupdate_error{$root_sites[0]} = "Error!";
$msg_userupdate_instruct{$root_sites[0]} = "Welcome,<br>Edit the following fields to modify your account and click \"Submit\" to continue...";
$msg_userupdate_username{$root_sites[0]} = "Username";
$msg_userupdate_password1{$root_sites[0]} = "Edit your password here:";
$msg_userupdate_password2{$root_sites[0]} = "Please enter your password again:";
$msg_userupdate_errors_instruct{$root_sites[0]} = "There were problems with your form. Those problems were:";
$msg_userupdate_passdontmatch{$root_sites[0]} = "The passwords you supplied did not match.";
$msg_userupdate_passtoosmall{$root_sites[0]} = "The password you supplied was too small.";
$msg_sorry_adminonly{$root_sites[0]} = "Sorry, this section of the web-site is for admins only!";
$msg_adminmain_dialog{$root_sites[0]} = "Web-site administration";
$msg_adminmain_instruct{$root_sites[0]} = "Welcome,<br>Please select one of the following options...";
$msg_adminmain_usermanage{$root_sites[0]} = "User Management";
$msg_adminmain_lockouts{$root_sites[0]} = "Administer Address/User Lockouts";
$msg_usermanage_dialog{$root_sites[0]} = "User Management";
$msg_usermanage_instruct{$root_sites[0]} = "Welcome,<br>Please select the user whish you would like to modify";
$msg_useredit_instruct{$root_sites[0]} = "Please edit the user's data";
$msg_useredit_username{$root_sites[0]} = "Username:";
$msg_useredit_password1{$root_sites[0]} = "Password:";
$msg_useredit_password2{$root_sites[0]} = "Enter new password again:";
$msg_useredit_groups{$root_sites[0]} = "Group affilations - seperate with commas `,':";
$msg_useredit_success{$root_sites[0]} = "The account has been updated...";
$msg_useredit_errors{$root_sites[0]} = "There were problems with your input. Those problems were:";
$msg_useredit_nameconflict{$root_sites[0]} = "The new username you supplied conflicted with an existing one";
$msg_useredit_passdontmatch{$root_sites[0]} = "The passwords you supplied did not match.";
$msg_useredit_passtoosmall{$root_sites[0]} = "The password you supplied was too small.";
$msg_useredit_back{$root_sites[0]} = "Click here to return to User Management";
$msg_sorry_cannotmodify{$root_sites[0]} = "Sorry, you cannot modify the requested account...";
$msg_delete_user{$root_sites[0]} = "DELETE";
$msg_deleteuser_dialog{$root_sites[0]} = "Delete User Confirmation";
$msg_deleteuser_instruct{$root_sites[0]} = "To delete this user, click \"DELETE\".<br>WARNING: A deleted user must be added again in order to have an account!";
$msg_deleteuser_error{$root_sites[0]} = "You are trying to delete a user which does not exist!";
$msg_deleteuser_success{$root_sites[0]} = "User was deleted.... You heartless bastard....";
$msg_account_added{$root_sites[0]} = "The requested account was successfully added...";
$msg_account_add_instruct{$root_sites[0]} = "Fill out the following form to add a new user...";
$msg_account_add_dialog{$root_sites[0]} = "Adding a New Account";
$msg_account_add_groups{$root_sites[0]} = "Input any and all groups user will be associated with (default to \"other\"):";
$msg_forum_empty{$root_sites[0]} = "This forum is empty";
$msg_forum_contains{$root_sites[0]} = "Current number of Posts:";
$msg_forum_new{$root_sites[0]} = "Post New Message";
$msg_forum_reply{$root_sites[0]} = "Reply to Message";
$msg_forum_title{$root_sites[0]} = "Title:";
$msg_forum_date{$root_sites[0]} = "Posted on:";
$msg_forum_from{$root_sites[0]} = "Posted by:";
$msg_forum_guest{$root_sites[0]} = "<i>Anonymous</i>";
$msg_forum_delthread{$root_sites[0]} = "Delete this thread";
$msg_forum_clear{$root_sites[0]} = "Click here to clear this forum";
$msg_forum_delsure{$root_sites[0]} = "Are you sure you wish to delete this thread?";
$msg_forum_delcancel{$root_sites[0]} = "Delete was cancelled... click here to return to forum...";
$msg_forum_deldone{$root_sites[0]} = "Thread deleted... click here to return to forum...";
$msg_forum_clearsure{$root_sites[0]} = "Are you sure you wish to clear this forum? It cannot be recovered!";
$msg_click_here{$root_sites[0]} = "Click Here";
$msg_forum_instruct{$root_sites[0]} = "Fill in message, when finished, click `SUBMIT'";
$msg_forum_validhtml{$root_sites[0]} = "Valid HTML tags are &#060a href=\"\"&#062, &#060br&#062, &#060p&#062, &#060b&#062, &#060i&#062, and &#060u&#062";
$msg_post_success{$root_sites[0]} = "Submission successful, click here to return to forum...";
$msg_post_error_notfill{$root_sites[0]} = "Submission error! Fields not filled out! Press \"back\" on your browser to correct or click here to return to forum...";
$msg_post_error_wrongid{$root_sites[0]} = "Submission error! Somehow your id does not match! Press \"back\" on your browser to correct or click here to return to forum...";
$msg_forum_more{$root_sites[0]} = "Click here for more posts...";
$msg_can_update{$root_sites[0]} = "Click here to update this entry";
$msg_archive_site{$root_sites[0]} = "Click here to archive this site";
$msg_archive_dialog{$root_sites[0]} = "Site Archiving Dialog";
$msg_archive_instruct{$root_sites[0]} = "WARNING!<br>You have selected the site-archive dialog!<br>By selecting YES you will archive this web-site in its entirety!";
$msg_archive_dstamp{$root_sites[0]} = "The current date stamp is:";
$msg_archive_dindex{$root_sites[0]} = "The current date index is:";
$msg_archive_certain{$root_sites[0]} = "Are you certain you wish to archive right now?";
$msg_archive_cancel{$root_sites[0]} = "Action cancelled, click here to return to main screen...";
$msg_archive_working{$root_sites[0]} = "Presently archiving the site... please standby....";
$msg_archive_done{$root_sites[0]} = "Archival complete.... click here to return to main screen...";
$msg_pre_year{$root_sites[0]} = "Archives for the year";
$msg_post_year{$root_sites[0]} = "AD";
$msg_pre_month{$root_sites[0]} = "Archives for the month";
$msg_post_month{$root_sites[0]} = "click here";
$msg_pre_day{$root_sites[0]} = "Archive for";
$msg_post_day{$root_sites[0]} = "...";

##############################
# Personal Data Extras
##############################
# Use these to add any other
# information you want on each
# person (up to 5 per site)
##############################

$extras_used{$root_sites[0]} = 2;	#can be 0...5
$msg_extra{$root_sites[0]}[1] = "E-mail address";
$type_extra{$root_sites[0]}[1] = $extra_email;
$msg_extra{$root_sites[0]}[2] = "Home page URL";
$type_extra{$root_sites[0]}[2] = $extra_url;

$privacy_policy{$root_sites[0]} = "Click <a href=\"http://www.geekcomix.com/privacy_policy.html\">here</a> for our privacy policy"; # Your privacy policy link

#undef $email_remind{$root_sites[0]}; #Uncomment this if you do not want to allow users to send e-mail to themselves reminding them of their password
$email_remind{$root_sites[0]} = 1; # This should direct the system to the entry in the extra file which contains the users email (it also is the same as the extra arrays listed just above)

###############################
# Site administration
###############################

$default_admin_passwd{$root_sites[0]} = "admin";
$users_add_own_accounts{$root_sites[0]} = $yes;
$default_group{$root_sites[0]} = "other";

################# testb SITE SPECIFICS ##########################

#########################################
# Site specifications:
#----------------------------------------
# These are for various title, default
# colors, and metatag items for each site
#########################################

$title{$root_sites[1]} = "Testing Site b";
$URL{$root_sites[1]} = "http://www.geekcomix.com/noink/testb/";
$classification{$root_sites[1]} = "Noink Example";
$description{$root_sites[1]} = "Noink Example";
$keywords{$root_sites[1]} = "linux, perl, noink, cgi, images, content, gnu, free, software, web";
$rating{$root_sites[1]} = "none";
$copyright{$root_sites[1]} = "Copyright (c) 2000 Sam Hart";
$author{$root_sites[1]} = "Sam Hart";
$replyto{$root_sites[1]} = "hart\@geekcomix.com";
$language{$root_sites[1]} = "English";
$section_sep{$root_sites[1]} = "<br><hr size=2 width=\"100%\">";

$RearColor{$root_sites[1]} = "FFFBD3";
$PlainText{$root_sites[1]} = "000000";
$Vlink{$root_sites[1]} = "006400";
$link{$root_sites[1]} = "2E8B57";
$BGColor{$root_sites[1]} = "B2AB47";
$HeadBGColor{$root_sites[1]} = "EE7942";
$AdminBGColor{$root_sites[1]} = "FF6A6A";
$AdminBGLight{$root_sites[1]} = "CD9B9B";

$main_width{$root_sites[1]} = "70%";

$topbar_w{$root_sites[1]} = "100%";
$topbar_border{$root_sites[1]} = "0";
$topbar_padding{$root_sites[1]} = "5";
$topbar_spacing{$root_sites[1]} = "5";

$logo_width{$root_sites[1]} = "40%";

$page_width{$root_sites[1]} = "100%";
$page_border{$root_sites[1]} = "0";
$page_padding{$root_sites[1]} = "4";
$page_spacing{$root_sites[1]} = "0";

$leftbar_w{$root_sites[1]} = "10%";

$loginbox_w{$root_sites[1]} = "25%";

$min_password_size{$root_sites[1]} = 2;

$remindpassword_size{$root_sites[1]} = 5;

############################
# Forum Specifics:
#---------------------------
# Various form defaults and
# other configurations.
############################

$default_forum_depth{$root_sites[1]} = 3;
$default_forum_perscreen{$root_sites[1]} = 5;
$forum_max_inner{$root_sites[1]} = 5;
$forum_maxlength{$root_sites[1]} = 100; #lines or newlines

$forum_header_BGColor{$root_sites[1]} = "FF3030";
$forum_post_BGColor{$root_sites[1]} = "FF8C69";

$forum_reply_pre{$root_sites[1]} = "REPLY-TO: ";

################################
# Archive Specifics:
#-------------------------------
# Exactly what are our archiving
# policies?
################################

$can_archive{$root_sites[1]} = $yes;

###############################
# File Specifics:
#------------------------------
# What and where noink is to
# look for things
###############################

$leftbar_file{$root_sites[1]} = "/home/geekcomix/www/noink/testb/leftbar.html";
$rightbar_file{$root_sites[1]} = "/home/geekcomix/www/noink/testb/rightbar.html";
$topbar_file{$root_sites[1]}= "/home/geekcomix/www/noink/testb/topbar.html";
$data_root{$root_sites[1]} = "/home/geekcomix/www/noink/testb/data/";
$admin_root{$root_sites[1]} = "/home/geekcomix/www/noink/testb/admin/";
$archive_root{$root_sites[1]} = "/home/geekcomix/www/noink/testb/archives/";
$site_archive_root{$root_sites[1]} = "/noink/testb/archives/";
$site_root{$root_sites[1]} = "/noink/testb/data/";

###############################
# Contact Specifics:
#------------------------------
# Who to contact and what pages
# for additional reference.
###############################

$mail_admin{$root_sites[1]} = "hart\@geekcomix.com";

###############################
# Message Specifics:
#------------------------------
# What messages and output
# noink is supposed to use
###############################

$msg_nodata{$root_sites[1]} = "No data available! Please contact administrator as <a href=\"mailto:$mail_admin{$root_sites[1]}\">$mail_admin{$root_sites[1]}</a>!";
$msg_forum{$root_sites[1]} = "Click here to use the <i>forum</i>...";
$msg_loginbar{$root_sites[1]} = "SYSTEM LOGIN";
$msg_adminbar{$root_sites[1]} = " Administration";
$msg_welcome{$root_sites[1]} = "Welcome mine Snupck";
$msg_crack{$root_sites[1]} = "You are a suspected cracker";
$msg_username{$root_sites[1]} = "Input Username:";
$msg_password{$root_sites[1]} = "Input Password:";
$msg_newuser{$root_sites[1]} = "Or click here you create an account if a new user...";
$msg_userconfig{$root_sites[1]} = "Click here to configure your account";
$msg_adminconfig{$root_sites[1]} = "Click here to administer this site";
$msg_featuresorry{$root_sites[1]} = "<b>Sorry, this feature is not yet implimented....</b>";
$msg_add_user_sorry{$root_sites[1]} = "<b>To obtain an account on this site please contact <a href=\"mailto:$mail_admin{$root_sites[1]}\">$mail_admin{$root_sites[1]}</a>!";
$msg_newuserdialog{$root_sites[1]} = "New User Dialog";
$msg_newuser_instruct{$root_sites[1]} = "Welcome,<br>To obtain an account on this web-site, please fill out the following form in its entirety.";
$msg_newuser_username{$root_sites[1]} = "Please enter a User Name:";
$msg_newuser_password1{$root_sites[1]} = "Please enter a password:";
$msg_newuser_password2{$root_sites[1]} = "Please enter your password again:";
$msg_newuserdialog_error{$root_sites[1]} = "Error!";
$msg_newuser_errors_instruct{$root_sites[1]} = "There were problems with your form. Those problems were:";
$msg_newuser_nametaken{$root_sites[1]} = "The name you chose has already be taken.";
$msg_newuser_passdontmatch{$root_sites[1]} = "The passwords you supplied did not match.";
$msg_newuser_passtoosmall{$root_sites[1]} = "The password you supplied was too small.";
$msg_newuser_success{$root_sites[1]} = "Your account has been created! Click <a href=\"http://www.geekcomix.com/noink/testa/\">here</a> to return to main screen...";
$msg_email_remind{$root_sites[1]} = "Forgotten your password? Click here....";
$msg_passremind_subject{$root_sites[1]} = "Password Remind";
$msg_passremind_head{$root_sites[1]} = "Your password is: ";
$msg_passremind_foot{$root_sites[1]} = "\n\nPlease change it as soon as you logon!\n\n\cD";
$msg_password_sent{$root_sites[1]} = "Your password has been sent...";
$msg_passremind_dialog{$root_sites[1]} = "Password Remind Dialog";
$msg_passremind_dialog_error{$root_sites[1]} = "Error!";
$msg_passremind_instruct{$root_sites[1]} = "Welcome,<br>To have your e-mail sent to you, please fill out your valid username...";
$msg_passremind_username{$root_sites[1]} = "Username";
$msg_passremind_errors_instruct{$root_sites[1]} = "There were problems with your request. Those problems were:";
$msg_passremind_nomatch{$root_sites[1]} = "There is no account with this username.";
$msg_passremind_emailprob{$root_sites[1]} = "The account you specified has problems with its e-mail... Please contact the administrator at <a href=\"mailto:$mail_admin{$root_sites[1]}\">$mail_admin{$root_sites[1]}</a>!";
$msg_passremind_badaccount{$root_sites[1]} = "The account you specified was not valid.";
$msg_already_logon{$root_sites[1]} = "Sorry... you appear to already be logged in...";
$msg_userupdate_success{$root_sites[1]} = "Your account has been updated! Click <a href=\"http://www.geekcomix.com/noink/testa/\">here</a> to return to main screen... (For security reasons, you may need to relogin!)";
$msg_userupdate{$root_sites[1]} = "User Configuration";
$msg_userupdate_error{$root_sites[1]} = "Error!";
$msg_userupdate_instruct{$root_sites[1]} = "Welcome,<br>Edit the following fields to modify your account and click \"Submit\" to continue...";
$msg_userupdate_username{$root_sites[1]} = "Username";
$msg_userupdate_password1{$root_sites[1]} = "Edit your password here:";
$msg_userupdate_password2{$root_sites[1]} = "Please enter your password again:";
$msg_userupdate_errors_instruct{$root_sites[1]} = "There were problems with your form. Those problems were:";
$msg_userupdate_passdontmatch{$root_sites[1]} = "The passwords you supplied did not match.";
$msg_userupdate_passtoosmall{$root_sites[1]} = "The password you supplied was too small.";
$msg_sorry_adminonly{$root_sites[1]} = "Sorry, this section of the web-site is for admins only!";
$msg_adminmain_dialog{$root_sites[1]} = "Web-site administration";
$msg_adminmain_instruct{$root_sites[1]} = "Welcome,<br>Please select one of the following options...";
$msg_adminmain_usermanage{$root_sites[1]} = "User Management";
$msg_adminmain_lockouts{$root_sites[1]} = "Administer Address/User Lockouts";
$msg_usermanage_dialog{$root_sites[1]} = "User Management";
$msg_usermanage_instruct{$root_sites[1]} = "Welcome,<br>Please select the user whish you would like to modify";
$msg_useredit_instruct{$root_sites[1]} = "Please edit the user's data";
$msg_useredit_username{$root_sites[1]} = "Username:";
$msg_useredit_password1{$root_sites[1]} = "Password:";
$msg_useredit_password2{$root_sites[1]} = "Enter new password again:";
$msg_useredit_groups{$root_sites[1]} = "Group affilations - seperate with commas `,':";
$msg_useredit_success{$root_sites[1]} = "The account has been updated...";
$msg_useredit_errors{$root_sites[1]} = "There were problems with your input. Those problems were:";
$msg_useredit_nameconflict{$root_sites[1]} = "The new username you supplied conflicted with an existing one";
$msg_useredit_passdontmatch{$root_sites[1]} = "The passwords you supplied did not match.";
$msg_useredit_passtoosmall{$root_sites[1]} = "The password you supplied was too small.";
$msg_useredit_back{$root_sites[1]} = "Click here to return to User Management";
$msg_sorry_cannotmodify{$root_sites[1]} = "Sorry, you cannot modify the requested account...";
$msg_delete_user{$root_sites[1]} = "DELETE";
$msg_deleteuser_dialog{$root_sites[1]} = "Delete User Confirmation";
$msg_deleteuser_instruct{$root_sites[1]} = "To delete this user, click \"DELETE\".<br>WARNING: A deleted user must be added again in order to have an account!";
$msg_deleteuser_error{$root_sites[1]} = "You are trying to delete a user which does not exist!";
$msg_deleteuser_success{$root_sites[1]} = "User was deleted.... You heartless bastard....";
$msg_account_added{$root_sites[1]} = "The requested account was successfully added...";
$msg_account_add_instruct{$root_sites[1]} = "Fill out the following form to add a new user...";
$msg_account_add_dialog{$root_sites[1]} = "Adding a New Account";
$msg_account_add_groups{$root_sites[1]} = "Input any and all groups user will be associated with (default to \"other\"):";
$msg_forum_empty{$root_sites[1]} = "This forum is empty";
$msg_forum_contains{$root_sites[1]} = "Current number of Posts:";
$msg_forum_new{$root_sites[1]} = "Post New Message";
$msg_forum_reply{$root_sites[1]} = "Reply to Message";
$msg_forum_title{$root_sites[1]} = "Title:";
$msg_forum_date{$root_sites[1]} = "Posted on:";
$msg_forum_from{$root_sites[1]} = "Posted by:";
$msg_forum_guest{$root_sites[1]} = "<i>SOME UN-NAMED SCHMOE</i>";
$msg_forum_delthread{$root_sites[1]} = "Delete this thread";
$msg_forum_clear{$root_sites[1]} = "Click here to clear this forum";
$msg_forum_delsure{$root_sites[1]} = "Are you sure you wish to delete this thread?";
$msg_forum_delcancel{$root_sites[1]} = "Delete was cancelled... click here to return to forum...";
$msg_forum_deldone{$root_sites[1]} = "Thread deleted... click here to return to forum...";
$msg_forum_clearsure{$root_sites[1]} = "Are you sure you wish to clear this forum? It cannot be recovered!";
$msg_click_here{$root_sites[1]} = "Click Here";
$msg_forum_instruct{$root_sites[1]} = "Fill in message, when finished, click `SUBMIT'";
$msg_forum_validhtml{$root_sites[1]} = "Valid HTML tags are &#060a href=\"\"&#062, &#060br&#062, &#060p&#062, &#060b&#062, &#060i&#062, and &#060u&#062";
$msg_post_success{$root_sites[1]} = "Submission successful, click here to return to forum...";
$msg_post_error_notfill{$root_sites[1]} = "Submission error! Fields not filled out! Press \"back\" on your browser to correct or click here to return to forum...";
$msg_post_error_wrongid{$root_sites[1]} = "Submission error! Somehow your id does not match! Press \"back\" on your browser to correct or click here to return to forum...";
$msg_forum_more{$root_sites[1]} = "Click here for more posts...";
$msg_can_update{$root_sites[1]} = "Click here to update this entry";
$msg_archive_site{$root_sites[1]} = "Click here to archive this site";
$msg_archive_dialog{$root_sites[1]} = "Site Archiving Dialog";
$msg_archive_instruct{$root_sites[1]} = "WARNING!<br>You have selected the site-archive dialog!<br>By selecting YES you will archive this web-site in its entirety!";
$msg_archive_dstamp{$root_sites[1]} = "The current date stamp is:";
$msg_archive_dindex{$root_sites[1]} = "The current date index is:";
$msg_archive_certain{$root_sites[1]} = "Are you certain you wish to archive right now?";
$msg_archive_cancel{$root_sites[1]} = "Action cancelled, click here to return to main screen...";
$msg_archive_working{$root_sites[1]} = "Presently archiving the site... please standby....";
$msg_archive_done{$root_sites[1]} = "Archival complete.... click here to return to main screen...";
$msg_pre_year{$root_sites[1]} = "Archives for the year";
$msg_post_year{$root_sites[1]} = "AD";
$msg_pre_month{$root_sites[1]} = "Archives for the month";
$msg_post_month{$root_sites[1]} = "click here";
$msg_pre_day{$root_sites[1]} = "Archive for";
$msg_post_day{$root_sites[1]} = "...";

##############################
# Personal Data Extras
##############################
# Use these to add any other
# information you want on each
# person (up to 5 per site)
##############################

$extras_used{$root_sites[1]} = 2;	#can be 0...5
$msg_extra{$root_sites[1]}[1] = "E-mail address";
$type_extra{$root_sites[1]}[1] = $extra_email;
$msg_extra{$root_sites[1]}[2] = "Home page URL";
$type_extra{$root_sites[1]}[2] = $extra_url;

$privacy_policy{$root_sites[1]} = "Click <a href=\"http://www.geekcomix.com/privacy_policy.html\">here</a> for our privacy policy"; # Your privacy policy link

#undef $email_remind{$root_sites[1]}; #Uncomment this if you do not want to allow users to send e-mail to themselves reminding them of their password
$email_remind{$root_sites[1]} = 1; # This should direct the system to the entry in the extra file which contains the users email (it also is the same as the extra arrays listed just above)

###############################
# Site administration
###############################

$default_admin_passwd{$root_sites[1]} = "admin";
$users_add_own_accounts{$root_sites[1]} = $yes;
$default_group{$root_sites[1]} = "other";


################################################################
################################################################
# Declarations independant of root sites

$noink_cgi = "http://www.geekcomix.com/cgi-bin/noink/noink.cgi";

$blank_space = "&nbsp;&nbsp;";

$mail_interface = "/bin/mail";
$mail_subject = "-s";
$mail_cc = "-c";
$mail_to = " ";

$date_options_wkdy = 'date +%A';
$date_options_daynum = 'date +%d';
$date_options_month = 'date +%b';
$date_options_year = 'date +%Y';
$date_options_time = 'date +%T';
$date_general = 'date';
$date_archive_stamp = 'date +"%Y%b%d%H%M"';
$date_archive_index = 'date +"%A, %b %d %Y @ %k:%M"';

$delete_rec_f = 'rm -fR';

$copy_rec_f = 'cp -fR';

$pre_lynx = "TERM=\"xterm\"\n";
$lynx = '/usr/bin/lynx';
$lynx_options = '-source';

$ls = 'ls';
$dir_sep = '/';