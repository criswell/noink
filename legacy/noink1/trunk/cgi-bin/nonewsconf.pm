# nonewsconf.pm
# -------------
# NoNews General Config file
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
# File Allocation

# All "location" prefixed varis should have fully qualified paths, including end and beginning `/'s.
# e.g.; /root/somedir/some-other-dir/my_files/
$location_configs = "/somewhere/somewhere-else/";

$location_admin = "/somewhere/admin/";

$location_banner = "/www/univ/banner.html";

# As accessed from the web, e.g. "~hart/my_images/" or "/images/nonews/topics/"
$location_topics = "/somewhere/topics/";
$extension_topic = ".png";
$prefix_mini = "_mini";

# As accessed from the web
$location_nonews = "/somewhere/cgi-bin/nonews.cgi";

#####################
# Server specifics

# The server IP address
$server_ip = $ENV{SERVER_ADDR};

#####################
# Text specifics

$text_replies = "Replies :";
$text_more = "Read More...";
$text_similar_search = "Similar Items";
$text_post_new = "Post a new follow-up";
$text_no_posts = "Forum is empty...";
$text_more_posts = "Posts not displayed :";

;