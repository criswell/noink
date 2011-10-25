#!/usr/bin/perl -w
# noUtil.pm
package noUtil;

# --------
# Common Noink2 utils (use only if your app needs them, to keep Noink2 lean ;-)
#
#    Copyright (C) 2001 Sam Hart
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; version 2 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

BEGIN { }

#---------------------------------------------------------------------
# Input routines
#---------------------------------------------------------------------

# conInput - Standard console input, returns line typed to console
sub conInput {
        my $in;
        INPUT: while ($in = <STDIN>) {
                last INPUT;
        }
        chomp $in;
        return $in;
}

END { };
1;
