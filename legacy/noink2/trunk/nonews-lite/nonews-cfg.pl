#!/usr/bin/perl
package newscfg;
#==========================================================================
# nonews-lite config file -- Edit to suit your needs
#==========================================================================
#
# Note to mod_perl users: comment out the print statment at the bottom of
# this config file if you're seeing an extra content-type header displayed.

# Change this to the URL of installed script
$scriptURL = 'http://localhost/cgi-bin/nonews-lite/nonews-lite.cgi';

# The file in which the current news items are kept. This file
# should be included in your target web page through the use of
# a Server Side Include tag (SSI). This is a path NOT a URL!
# for example:  <!--#include file="todays.news" -->
$newsFile = '/home/webpages/todays.news';

# The file with the current headlines with html links
$headlineFile = '/home/webpages/headlines.news';

# The directory in which archived news files should be stored.
# This is a path NOT a URL!
$archivePath = '/home/webpages/oldnews';

# The URL of the main news page
$mainURL = 'http://localhost/test.shtml';

# The URL of the archived news directory
$arcURL = 'http://localhost/oldnews/';

# Each news archive file will be named year-mon$arcSuffix
# The default setting results in file names like 2000-Jan-news.html
$arcSuffix = '-news.html';

# After posting a news item, the new script will redirect the
# user to this URL. Usually this should be the target web page
# that includes the file referenced in $newsFile. If you are
# not using SSIs, this could be the same as $newsFile.
$redirect = 'http://localhost/test.shtml';

# Indicate a temporary directory that can be used to write working
# files for editing and previewpurposes. The default value should
# work on mostsystems. This is a path NOT a URL.
$tmpDir = '/tmp';

# MaxItems is the number of recent news items you would like to
# show in your current newsfile. If there are more news items
# than this, older items will be moved into the archive.
$MaxItems = 4;

# The index page for the new archive can list old news in either ascending
# or descending order by date. The default is ascending order with newer
# months listed after older months. To sort in descending order set to 0
$ArcSortAscending = 1;

# If the server running the nonews-lite program is in a different timezone
# than the one you usually post from, you can correct the time and date
# information posted with each news item here. The offset value is
# specfied in seconds (yeah, I know but making you calculate it once
# saves the program from having to calculate it each and every time you
# post). For example:
#
# If you are one hour ahead of the time zone where the server is:
# $DateOffset = 3600;
#
# If you are one hour behind the time zone where the server is:
# $DateOffset = -3600;
#
$DateOffset = 0;

# Edit the contents of the preview header & footer to contain any
# HTML code you need to give the preview the appearance of your
# target web page layout. The previewHeader should NOT include
# the any HTML tags that occur prior to the <body> tag. The footer
# should NOT include the </body> or </html> tag as these will be
# provided by the script.

@previewHeader = (
    "/path/somewhere/file1.html",
    "/path/somewhere/file2.html"
);

@previewFooter = (
    "/path/somewhere/file3.html",
    "/path/elsewhere/file4.html"
);

# Edit the contents of the archive header & footer to contain any
# HTML code you'd like to customize the look.

@archiveHeader = (
    "/path/somewhere/arch1.html",
    "/path/elsewhere/arch2.html"
);

@archiveFooter = (
    "/path/somewhere/arch3.html",
    "/path/somewhere/arch4.html"
};

# Edit the contents of the archive index header & footer to contain any
# HTML code you'd like to customize the look.

@archIndexHeader = (
    "/path/blah/index1.html",
    "/other/path/index2.html"
);

@archIndexFooter = (
    "/path/path/argh1.html",
    "/goo/poo/argh2.html"
);


#------------------------------------------------------------------------#
# Distributed P2P news delivery section
#------------------------------------------------------------------------#
$cfg_dir = "/opt/webscripts/nonews";
$min_line_length = 60;

$authentication_url = "http://www.tux4kids.net/nonews/nonews-p2p-cgi?";

# mod_virgule diary - Using this option will allow you to post your
# news entries to a mod_virgule diary simulatneously if you also have an
# account on such as system (e.g. advogato.org. If you do not need this
# or if you do not understand what this will do, Leave these setting empty!

# To get your cookie value, you will need to look in your Netscape cookie
# file after logging in to the mod_virgule site. It will consist of your
# username, a colon, and a random code. Example: 'username:iek8DiKKoiweLDE'
$virguleCookie = '';

# Name of the host that you want to post a diary entry to.
# Example 'advogato.org'
$virguleDomain = '';

# Path to the diary post function on the mod_virgule server.
# On advogato.org this is '/diary/post.html'
$virguleDiary  = '';

# Full URL of your diary page on the mod_virgule server. This is used
# to provide a convenient link to your page after posting.
# Example: 'http://advogato.org/person/fred/'
$virguleRedirect = '';

# End of mod_virgule configuration options


# Comment this line out if using mod_perl with PerlSendHeader=OFF
# to prevent duplicate content-type headers
print "Content-type: text/html\n\n";

# do not remove or comment out the following!
__END__
1;
