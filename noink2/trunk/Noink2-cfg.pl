#!/usr/bin/perl
package Noink2_cfg;
#==========================================================================
#
# Noink2 master configuration file.
#
#==========================================================================
#
# Note to mod_perl users: comment out the print statment at the bottom of
# this config file if you're seeing an extra content-type header displayed.

# Noink2 Root Directory:
# This is the root directory of the Noink2 system
$root_dir = "/home/sam/work/temp/noink2";

# Noink2 Home Directory
# This is the root for the user home directory
$home_dir = "/home/sam/work/temp/noink2/home";

# Administrator's login in
$admin_id = "root";

# Administrator's password
$admin_pwd = "poopie";

# Administrator's home dir
$admin_home = "root";

# Administration group id
$admin_group = "admin";

# Maximum errors on error queue before queue cycles
$max_errs = 20;

#--DEFAULT USER SETTINGS
# Default group (if none)
$default_group = "none";

# Noink2 headers and footers
# This first one is for the Noink2 HTML-style headers
$html_header = <<"EOF";
<table width="90%" border="0" bgcolor="#006c92">
<tr><td><a href="http://www.geekcomix.com/noink2/"><img
src="images/noink2-logo.png" border="0" align="left" alt="powered by Noink2" />
</a></td></tr><tr><td>
EOF

#># This next one is the footer
$html_footer = <<"EOF";
</td></tr></table>
EOF

#># This is the header for plain-text apps
$text_header = <<"EOF";
__ powered by Noink2 ;-)
EOF

# this is the footer for plain-text apps
$text_footer = <<"EOF";
___
EOF

# ==========================================================================
# Advanced Configuration Items follow. DO NOT EDIT UNLESS YOU KNOW WHAT YOU
# ARE DOING!
# ==========================================================================

# Deliminator: This is the character that deliminates the password/group files
# No group, user name, or password can have this character in it
$_delim_ = ":";

# Second Deliminator: This is the character that deliminates the uids in the
# group file. This cannot be a number, and cannot be $_delim_
$_delim2_ = ",";

# do not remove or comment out the following!
__END__
1;
