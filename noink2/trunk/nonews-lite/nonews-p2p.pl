#!/usr/bin/perl
#==========================================================================
# noNews - p2p distributor version 0.8.1
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

use Mail::Internet;
#$message = new Mail::Internet \*STDIN;
$main::version = '0.8.1';
$main::NewsItem = '';
$main::NewsTitle = '';
@main::newsItems = ();
%main::FORM = ();
$main::rcode = '';

$main::cfgName = 'nonews-cfg.pl';
if($main::FORM{'cfg'}) { $main::cfgName = $main::FORM{'cfg'}; }
do $main::cfgName or die "Unable to load or parse $main::cfgName!";

#First, let's see if we are a CGI script or a mail wrapper
if($ENV{'RECIPIENT'} eq  $main::recipient) {
    # We're a wrapper
} else if(defined $ENV{'HTTP_HOST'}) {
    # We're CGI
}
