#!/usr/bin/perl
#==========================================================================
# noNews - Lite version 0.8.1
#
# http://noink.sf.net/nonews-lite/
#
# Copyright (c) 2000, 2001 by Sam "Criswell" Hart <criswell@geekcomix.com>
#
# Special Thanks to Steven Rainwater for his phenom newslog from which
# code was based ;-)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#==========================================================================

use strict;
use FileHandle;
use IO::Socket;
STDOUT->autoflush(1);
$main::version = '0.8.1';
$main::NewsItem = '';
$main::NewsTitle = '';
@main::newsItems = ();
%main::FORM = ();
$main::rcode = '';

my ($name, $value, $pair) = ();

# Parse GET, POST data into pairs
my $buffer = $ENV{'QUERY_STRING'};
my @pairs = split(/&/, $buffer);
if($ENV{'REQUEST_METHOD'} eq 'POST') {
    $buffer = '';
    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    push(@pairs,split(/&/, $buffer));
}

# Make GET/POST pair hash
foreach $pair (@pairs) {
    ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
    $main::FORM{$name}=$value;
}

$main::cfgName = 'nonews-cfg.pl';
if($main::FORM{'cfg'}) { $main::cfgName = $main::FORM{'cfg'}; }
do $main::cfgName or die "Unable to load or parse $main::cfgName!";

$main::tmpfile = $newscfg::tmpDir . '/' . $main::cfgName . '-' . $ENV{'REMOTE_ADDR'};

# Build a timestamp
my @days = qw(Sun Mon Tue Wed Thu Fri Sat);
my ($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime(time + $newscfg::DateOffset);
@main::months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
$main::date = sprintf "%i %s %i (%s), %02i:%02i",1900+$year,$main::months[$mon],$mday,$days[$wday],$hour,$min;

$main::timestamp = "${year}${mon}${mday}${hour}${min}";
$main::datefilestamp = sprintf "%i-%s", 1900+$year, $main::months[$mon];
#print "${main::datefilestamp}\n";

my $command = $main::FORM{'command'} || '';

if($command eq 'post') { &post_item; }
elsif($command eq 'preview') { &preview_item; }
elsif($command eq 'edit') { &edit_item; }
else { &news_editor; }

# function news_editor - generates the news editor interface
sub news_editor {
    print << "EOF";
<html>
<head><title>News Editor</title>
<meta http-equiv="expires" content="0"></head>
<body bgcolor="#a0a0a0" link="#ffff00" vlink="#000088" alink="#00ffff"><center>
<table width="50%" bgcolor="#6699dd"><tr><td>
<table border="1">
<tr><td align="center" bgcolor="#0000aa"><font color="#ffffff" face="sans-serif" size="+1">
noNews-lite Version $main::version</font></td></tr>
<tr><td align="right">
<form method=POST action="$newscfg::scriptURL?command=preview">
<font size="-1">
<center><b>News Title</b><input type="text" name="newstitle" value="$main::NewsTitle" /> - Enter the Title of this
news item</center>
<textarea wrap=virtual name="newsitem" rows="20" cols="80">$main::NewsItem</textarea></font>
<table border="0"><tr><td align="left"><font size="-1"><b>News Editor </b>
&nbsp;Enter your news item in the space above. Then click the <i>Preview</i>
button to see what it will look like. The preview screen will offer the
option of further editing or final posting of the item.</font></td><td>
&nbsp;&nbsp;<input type="reset" value=" Clear ">&nbsp;&nbsp;</td><td>
<input type="submit" value="Preview">
<input type="hidden" name="cfg" value="$main::cfgName">
</td></tr></table>
</form>
</td></tr>
<tr><td align="center"><font size="-1">
<a href="http://www.geekcomix.com/soft/noink2/nonews-lite/">noNews-lite</a> Version $main::version &copy;
2000, 2001 by <a href="http://www.geekcomix.com/snh//">Sam "Criswel" Hart</a><br>
Licensed under the terms of the <a href="http://www.gnu.org/copyleft/gpl.html">
GNU GPL</a>
<br>Gazillions of thanks to <a href="http://www.ncc.com/humans/srainwater/">R. Steven Rainwater</a> for
making newslog and its mod_virgule support which formed the base of noNews-lite</font></td></tr>
</table></td></tr></table></center></body>
</html>
EOF
}


# function edit_item - reads temp file in slurp mode and loads into editor
sub edit_item {
    if(-e $main::tmpfile) {
	open TMPFILE, $main::tmpfile or die "Can't open temp file!\n";
    	undef $/;
	$main::NewsItem = <TMPFILE>;
    	close TMPFILE;
        undef $/;
        open (TMPFILE, "${main::tmpfile}-2"); # No dying here, just accept it ;-)
        $main::NewsTitle = <TMPFILE>;
        close TMPFILE;
    }
    &news_editor;
}


# function preview_item - save news item to temp file and show preview
sub preview_item {
    open (TMPFILE,">$main::tmpfile") or die "Can't open $main::tmpfile!\n";
    print TMPFILE $main::FORM{'newsitem'};
    close TMPFILE;
    open (TMPFILE,">${main::tmpfile}-2") or die "Can't open ${main::tempfile}-2!\n";
    print TMPFILE $main::FORM{'newstitle'};
    close TMPFILE;
    print '<html><head><title>News Item Preview</title><meta http-equiv="expires" content="0"></head>',"\n";
    foreach my $temp (@newscfg::previewHeader) {
        open(TMPFILE, "$temp") or die "Can't open header $temp!\n";
        my @text = <TMPFILE>;
        print @text;
        close TMPFILE;
    }
    print '<span class="nonewsTitle">',$main::FORM{'newstitle'},'</span>:&nbsp;<span class="nonewsDate">',$main::date,'</span><br>',
          '<span class="nonewsContent">',$main::FORM{'newsitem'},'</span>';
    foreach my $temp (@newscfg::previewFooter) {
        open(TMPFILE, "$temp") or die "Can't open footer $temp!\n";
        my @text = <TMPFILE>;
        print @text;
        close TMPFILE;
    }
    print "<center>\n",
          '[<a href="',$newscfg::scriptURL,'?cfg=',$main::cfgName,'&command=post">Post News Item</a>]&nbsp;&nbsp;&nbsp;',
          '[<a href="',$newscfg::scriptURL,'?cfg=',$main::cfgName,'&command=edit">Return to Editor</a>]<p>',
          '</center></body></html>',"\n";
}


# function post_item - reads temp file in slurp mode, then reads in the
# existing news items. New news items is prepended and an old item is
# moved into the archive if needed. News items are then written back out.
sub post_item {
    my $i = 1;
    my $line = '';
    my $refdate = '';

    # Read the temp file in slurp mode
    open TMPFILE, "< $main::tmpfile" or die "Can't open temp file $main::tmpfile!\n";
    undef $/;
    $main::NewsItem = <TMPFILE>;
    close TMPFILE;

    undef $/;
    open (TMPFILE, "${main::tmpfile}-2"); # No dying here, just accept it ;-)
    $main::NewsTitle = <TMPFILE>;
    close TMPFILE;

    unlink "${main::tmpfile}-2";

    # Read the current news items
    $/ = "\n";
    if(-e $newscfg::newsFile) {
	open TMPFILE, $newscfg::newsFile or die "Can't open $newscfg::newsFile for reading!\n";
	@main::newsItems = <TMPFILE>;
	close TMPFILE;
    }

    # Truncate the current news file and rewrite
    $refdate = $main::date;
    $refdate =~ s/\(\w{3}\)\,/-/;
    $refdate =~ s/\s+//g;
    open TMPFILE, ">$newscfg::newsFile" or die "Can't open $newscfg::newsFile for writing!\n";
    print TMPFILE "<!--$main::date-->\n";
    print TMPFILE "<a name='${main::timestamp}'><span class='nonewsTitle'>${main::NewsTitle}</span></a>:&nbsp;<span class='nonewsDate'>${main::date}</span><br>\n<span class='nonewsContent'>${main::NewsItem}</span><br><br>\n<!-- EOM -->\n";
    #print TMPFILE "<b>$main::date<a name=\"$refdate\"></a></b>&nbsp;$main::NewsItem\n<p>\n<!-- EOM -->\n";
    while($i < $newscfg::MaxItems) {
	    if(($line = shift @main::newsItems)) {
            print TMPFILE $line;
	        if($line =~ m/^<!-- EOM -->/) { $i++; }
	    }
	    else { $i=$newscfg::MaxItems; last; }
    }
    close(TMPFILE);

    &archive_items;

    $i = 1;

    # Now do the same thing with the headlines file
    $/ = "\n";
    if(-e $newscfg::headlineFile) {
	open TMPFILE, $newscfg::headlineFile or die "Can't open $newscfg::headlineFile for reading!\n";
	@main::newsItems = <TMPFILE>;
	close TMPFILE;
    }

    # Truncate the current headline file and rewrite
    $refdate = $main::date;
    $refdate =~ s/\(\w{3}\)\,/-/;
    $refdate =~ s/\s+//g;
    open TMPFILE, ">$newscfg::headlineFile" or die "Can't open $newscfg::headlineFile for writing!\n";
    print TMPFILE "<a href='${newscfg::mainURL}#${main::timestamp}'><span class='nonewsHeadline'>${main::NewsTitle}</span></a><br /><br />\n\n<!-- EOM -->\n\n";
    #print TMPFILE "<b>$main::date<a name=\"$refdate\"></a></b>&nbsp;$main::NewsItem\n<p>\n<!-- EOM -->\n";
    while($i < $newscfg::MaxItems) {
	    if(($line = shift @main::newsItems)) {
            print TMPFILE $line;
	        if($line =~ m/^<!-- EOM -->/) { $i++; }
	    }
	    else { $i=$newscfg::MaxItems; last; }
    }
    close(TMPFILE);

    unlink $main::tmpfile;
    my $redirectTime = 0;
    if($newscfg::virguleCookie) { &post_advo; $redirectTime = 10; };
    print '<html><head>',"\n",'<meta http-equiv="refresh" content="',$redirectTime,';URL=',$newscfg::redirect,'">',"\n",
          '<title>Posting Complete</title></head>',"\n",'<body bgcolor="#a0a0a0" link="#ffff00" vlink="#000088" alink="#00ffff">',
	  '<p>Posting completed. Your browser will shortly be redirected to your configured ',
	  'redirect page. Otherwise, click below to see your posted news entry<p>',
          'News item posted to: <a href="',$newscfg::redirect,'">',$newscfg::redirect,'</a><br>',"\n";
    if($newscfg::virguleCookie) {
	print 'Duplicate posted to: <a href="',$newscfg::virguleRedirect,'">',$newscfg::virguleRedirect,'</a> Response: <b>',$main::rcode,'</b><br>';
    }
    print '</body></html>',"\n";
}


# function archive_items - handles the actual archiving of old news
# item(s). A year-month value is determined for an item. A file with
# a matching value is opened or created and the item is appended.
# The old-news archive index.html file is regenerated to include
# links to all archive pages. There will normally only be one item
# to be archived unless the user has lowered the value of $maxItems
# since the previous run.
sub archive_items {
    my $fsize = 0;
    my $line = '';
    my $arcName = '';
    my @oldItems = ();
    my @sortedList = ();
    my $dd = "";

    while(@main::newsItems) {
        $main::newsItems[0] =~ m/^\D*(\d{4})\s+(\w*).*/;
        $arcName = "$newscfg::archivePath/$1-$2$newscfg::arcSuffix";
        #$arcName = "$newscfg::archivePath/${main::datefilestamp}$newscfg::arcSuffix";
        #print "$1-$2-$3-$4-$5-$6-$7-$8-$9-$10\n";
        #foreach $dd (@main::newsItems) {
        #        print "1-$dd\n";
        #}
        #print $arcName;
        if(-e $arcName) {
            open FILE, $arcName or die "Can't open $arcName for reading!\n";
            @oldItems = <FILE>;
            close FILE;
            open FILE, ">$arcName" or die "Can't open $arcName for writing!\n";
	        while(($line = shift @oldItems)) {
                if($line =~ m/^<!-- FOOTER -->/) { last; }
                print FILE $line;
            }
        }
        else {
            open FILE, ">$arcName" or die "Can't open $arcName for writing!\n";
            foreach my $temp (@newscfg::archiveHeader) {
                open HEADERFILE, "$temp" or die "Can't open header $temp!\n";
                my @headerIn = <HEADERFILE>;
                close HEADERFILE;
                print FILE @headerIn;
            }
            #print FILE $newscfg::archiveHeader;
        }
 	    while(($line = shift @main::newsItems)) {
            print FILE $line;
	        if($line =~ m/^<!-- EOM -->/) { last; }
	    }
        print FILE "<!-- FOOTER -->\n";
        foreach my $temp (@newscfg::archiveFooter) {
            open FOOTERFILE, "$temp" or die "Can't open footer $temp!\n";
            my @footerIn = <FOOTERFILE>;
            close FOOTERFILE;
            print FILE @footerIn;
        }
        #print FILE $newscfg::archiveFooter;
        close FILE;
    }
    opendir DIR, $newscfg::archivePath or die "Can't open directory $newscfg::archivePath for reading!\n";
    @oldItems = grep /^\d{4}/, readdir DIR;
    closedir DIR;
    if($newscfg::ArcSortAscending) { @sortedList = sort datesorter @oldItems; }
    else { @sortedList = reverse sort datesorter @oldItems; }
    open FILE, ">$newscfg::archivePath/index.shtml" or die "Can't open $newscfg::archivePath/index.shtml for writing!\n";
    foreach my $temp (@newscfg::arcIndexHeader) {
        open HEADERFILE, "$temp" or die "Can't open header $temp!\n";
        my @headerIn = <HEADERFILE>;
        close HEADERFILE;
        print FILE @headerIn;
    }
    #print FILE $newscfg::arcIndexHeader;
    print FILE '<table width="100%">';
    foreach $line (@sortedList) {
        if($line eq "index.shtml") { next; }
	$fsize = -s "$newscfg::archivePath/$line";
        $line =~ m/^(\d{4})-(\w{3}).*/;
        print FILE qq(<tr><td width="50%"><font face=sans-serif><a href="$line"><b>News from $1 $2</font></b></a></td><td align="right"><font face=sans-serif>$fsize</font></td><td align="left"><font face=sans-serif>&nbsp;bytes</font></td></tr>\n);
    }
    print FILE '</table>';
    foreach my $temp (@newscfg::arcIndexFooter) {
        open HEADERFILE, "$temp" or die "Can't open footer $temp!\n";
        my @headerIn = <HEADERFILE>;
        close HEADERFILE;
        print FILE @headerIn;
    }
    #print FILE $newscfg::arcIndexFooter;
    close FILE;
}

# function datesorter - simple function to sort three-letter month
# abbreviations + 4 digit years into the correct date order
sub datesorter {
    my ($aa, $bb, $ya, $yb) = ();
    $a =~ m/^(\d{4})-(\w{3}).*/;
    for($aa=0;$aa<12;$aa++) { if($main::months[$aa] eq $2) { $ya = $1; last; }}
    $b =~ m/^(\d{4})-(\w{3}).*/;
    for($bb=0;$bb<12;$bb++) { if($main::months[$bb] eq $2) { $yb = $1; last; }}
    $ya <=> $yb or $aa <=> $bb;
}

# function post_advo - post the current news items to the Advogato user
# diary set up in the config file
#
# Note: this function is a bit of kluge and will probably be replaced when
# someone has time to work out an XML import format for the mod_virgule
sub post_advo {
    $main::NewsItem =~ s/([^a-zA-Z0-9.-])/uc sprintf("%%%02x",ord($1))/eg;
    my $post = 'POST ' . $newscfg::virguleDiary . ' HTTP/1.0' . "\r\n" .
               'User-Agent: newslog ' . $main::version . "\r\n" .
	       'Host: ' . $newscfg::virguleDomain . "\r\n" .
	       'Cookie: id=' . $newscfg::virguleCookie . "\r\n" .
	       'Content-type: application/x-www-form-urlencoded' . "\r\n" .
	       'Content-length: ' . (23+(length $main::NewsItem)) . "\r\n\r\n" .
               'entry=' . $main::NewsItem . '&post=Post&key=-1' . "\r\n";

    my $sock = IO::Socket::INET->new(PeerAddr => $newscfg::virguleDomain,
                                     PeerPort => '80',
				     Proto    => 'tcp',
				     Type     => SOCK_STREAM);
    if($sock) {
	print $sock $post;
	$main::rcode = <$sock>;
	close $sock;
    }
}
