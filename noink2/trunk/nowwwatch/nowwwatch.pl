#!/usr/bin/perl
###!/usr/perl5/5.00503/bin/perl
#==========================================================================
# noWWWatch - version 0.0.1
#
# http://noink.sf.net/nowwwatch/
#
# Copyright (c) 2000, 2001 by Sam "Criswell" Hart <criswell@geekcomix.com>
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

$main::version = "0.0.1";

$main::mailer = "| /usr/bin/mail "; #-t";

use LWP::Simple;
use Digest::MD5 qw(md5_hex);

$main::cfgName = 'nowwwatch-cfg.pl';
do $main::cfgName or die "Unable to load or parse $main::cfgName!";

$main::message = "";
$main::datestamp = `/bin/date +\%Y-\%j-\%H:\%M:\%S`;

if(open(CHECK, "${watchcfg::check_dir}/sites.lst")) {
	my @sites = <CHECK>;
	close CHECK;
	chomp @sites;

	$main::message .= "noWWWatch results for ${main::datestamp}\n";
	$main::message .= "----------------------------------------\n\n";
	my @mds = ();
	$#mds = -1;
	if(open(MD, "${watchcfg::check_dir}/sites.md5")) {
		@mds = <MD>;
		close MD;
		chomp @mds;
	} else {
		#Errror, no MD5 file, create new one and alert admin
		$main::message .= "\tError, no MD5 checksum file... Creating new one\n\n";
	}
	# Proceed to check
	my $i = 0;
	for($i = 0; $i <= $#sites; $i++) {
		my $url = $sites[$i];
		my $htmlcheck = get("$url");
		my $checksum = md5_hex("$htmlcheck");
		if($i >= $#mds) {
			# its new, add to list
			$mds[$i] = $checksum;
		} else {
			# check against existing one
			if($checksum ne $mds[$i]) {
				# YIPES, MODIFIED!
				$main::message .= "SITE MODIFIED!\n\t$url\n";
				$mds[$i] = $checksum;
			} else {
				# Silently pass
			}
		}
	}

	if(open(MD, "> ${watchcfg::check_dir}/sites.md5")) {
		foreach my $md (@mds) {
			print MD "$md\n";
		}
		close MD;
	} else {
		$main::message .= "\tError, could not create MD5 checksum file\n\t${watchcfg::check_dir}/sites.md5\n\n\tCRITICAL ERROR! CHECK PERMISSIONS!\n";
	}

	#print $main::message;
} else {
	#Error, no check file
	$main::message .= "ERRROR! No Check file\n\t${watchcfg::check_dir}/sites.lst\n";
}

SendEmail($watchcfg::main_administrator, "nowwatch", "noreply", "nowwatch results", $main::message);

#-----------------------------------------------------------------------
# SendEmail : Send email, duh
#-----------------------------------------------------------------------
sub SendEmail {
  my ($to, $from, $reply, $subject, $message) = @_;
  if(open(MAILER, "${main::mailer} $to")) {
        print MAILER "From: $from\n";
        print MAILER "Reply-To: $reply\n";
        print MAILER "Subject: $subject\n\n";
        print MAILER $message . "\n";
        close MAILER;
  } else {
        # Uhm... error?
  }
}

