#!/usr/bin/perl -w
# noAdmin.pl

# --------
# Console-based Noink2 administration utility
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

use Noink2;
use noUtil;

my $n2 = Noink2->new;

# Register the application
$n2->register( -version => "0.0.1",
               -id => "noAdmin.pl",
               -name => "Noink2 Administration Utility",
               -group => "admin",
               -author => "Samuel Hart",
               -copyright => "GPL",
               -errorlevel => $Noink2::_ERR_WARN_,
               -apptype => $Noink2::_TYPE_PLAINTEXT_ );

#Globals
$app_time_out = 5;

#Main
&login;
&main_console;

# The login
sub login {
        LOGIN: while ( 1 eq 1 ) {
                $n2->display_header;
                print "\n\n$n2->{_app_name}\n----------------------------------------------------\n\n";
                print "Login: ";

                $username = &noUtil::conInput;

                print "Password: ";

                $password = &noUtil::conInput;

                print "\n";

                my $err = $n2->login_user( -username => $username,
                                           -password => $password );

                if($err eq $Noink2::_ERR_NONE_) {
                        $err = $n2->check_group;
                        if($err eq $Noink2::_ERR_NONE_) {
                                last LOGIN;
                        } else {
                                print "Sorry, you are not part of the admin group!\n";
                        }
                }
        }
}

# access the help sub-system
sub show_help {
        my @topics = @_;

        if($#topics eq -1) {
                #Default help display
                print "Command list:\n";
                print " adduser   deluser   addgroup  delgroup\n";
                print " lsuser    passwd    help      quit\n";

                print "\nUse 'help <command>' to see detailed help for\na command.\n\n";
        } else {
                INPUTPARSE: while($#topics > -1) {
                        my $cmd = shift(@topics);
                        if($cmd eq "help") {
                                print "'help' : Displays help on a topic\n\n";
                                print "When used alone will provide a list of\n";
                                print "possible commands. When followed by another\n";
                                print "command will display help on that command.\n\n";
                                last INPUTPARSE;
                        } elsif($cmd eq "quit") {
                                print "'quit' : Exits the Noink2 Admin console\n\n";
                                print "Will exit the Noink2 admin console. If used\n";
                                print "with the parameter '-f' will not prompt before\n";
                                print "exitting\n\n";
                                last INPUTPARSE;
                        } elsif($cmd eq "passwd") {
                                print "'passwd' : Changes a users password\n\n";
                                print "If called without any extra paramters will change\n";
                                print "the current user's password. If called with valid\n";
                                print "usernames as parameters will proceed through\n";
                                print "those usernames and allow you to change each\n";
                                print "user's password.\n\n";
                                last INPUTPARSE;
                        } elsif($cmd eq "adduser") {
                                print "'adduser' : Adds a new user\n\n";
                                print "Must be called with a name or list of names to be\n";
                                print "added to the Noink2 system.\n\n";
                                last INPUTPARSE;
                        } elsif($cmd eq "deluser") {
                                print "'deluser' : Deletes a user\n\n";
                                print "Must be called with a name or list of names to be\n";
                                print "deleted to the Noink2 system. If used with the\n";
                                print "parameter '-f', all usernames after -f will not\n";
                                print "prompt before deletion.\n\n";
                                print "NOTE: The administrator account cannot be deleted.\n\n";
                                last INPUTPARSE;
                        } elsif($cmd eq "lsuser") {
                                print "'lsuser' : Lists the users on the system\n\n";
                                print "If called with no user name, will list all users on\n";
                                print "the Noink2 system. Else, will only list (or verify)\n";
                                print "those user names supplied. If called with '-v' will\n";
                                print "list each user name in verbose mode (list home directory\n";
                                print "and user ID)\n\n";
                                last INPUTPARSE;
                        } elsif($cmd eq "addgroup") {
                                print "'addgroup' : Adds a new user group (app group)\n\n";
                                print "Must be called with a name or list of groups to be\n";
                                print "added to the Noink2 system.\n\n";
                                last INPUTPARSE;
                        } else {
                                print "No help found on topic '$cmd'\n";
                                last INPUTPARSE;
                        }
                }
        }
}

# List users
sub lsuser {
        my @unames = @_;
        my @lst;
        my $cols = $Noink2::_DEFAULT_;

        if($#unames == 0) {
                if($unames[0] eq "-v") {
                        $cols = $Noink2::_EXTENDED_;
                        pop(@unames);
                }
        }

        if($#unames > -1) {
                foreach my $name (@unames) {
                        if($name eq "-v") {
                                $cols = $Noink2::_EXTENDED_;
                        }
                        push(@lst, $n2->lsuser( -username => $name, -type => $cols ) );
                }
        } else {
                @lst = $n2->lsuser( -type => $cols );
        }

        foreach my $line (@lst) {
                print "$line ";
                if($cols eq $Noink2::_EXTENDED_) {
                        print "\n";
                }
        }
        print "\n\n";
}

# Delete a user
sub deluser {
        my @unames = @_;
        my $prompt = 1;
        if($#unames > -1) {
                foreach my $name (@unames) {
                        if($name eq "-f") {
                                $prompt = 0;
                        } else {
                                if($n2->user_exist($name) eq $Noink2::_ERR_NONE_) {
                                        my $proceed = "y";
                                        if($prompt == 1) {
                                                $proceed = "N"; # Change default for prompt ;-)
                                                print "Delete '$name', are you sure (y/N): ";
                                                $proceed = &noUtil::conInput;
                                        }
                                        if($proceed eq "y" || $proceed eq "Y") {
                                                $n2->deluser( -username => $name );
                                        }
                                } else {
                                        print "The user '$name' does not exist, skipping.\n";
                                }
                        }
                }
        } else {
                print "Please enter at least one user name\n";
        }
}

# Add a new group
sub addgroup {
        my @gnames = @_;
        if($#gnames > -1) {
                foreach my $group (@gnames) {
                        if($n2->group_exist($group) ne $Noink2::_ERR_NONE_) {
                                print "Adding group '$group'\n";
                                if($n2->add_group( -groupname => $group ) ne $Noink2::_ERR_NONE_) {
                                        print "Problem adding group!\n";
                                } else {
                                        print "Successfully added group...\n";
                                }
                        } else {
                                print "Sorry, cannot add the group '$group': Group already exists!\n";
                        }
                }
        } else {
                print "Please enter at least one group name!\n";
        }
}

# Add a new user
sub adduser {
        my @unames = @_;
        my $new_pass1;
        my $new_pass2;
        my $new_home;
        if($#unames > -1) {
                foreach my $name (@unames) {
                        if($n2->user_exist($name) ne $Noink2::_ERR_NONE_) {
                                print "Adding user '$name'\n";
                                my $times = 0;
                                PASSENTRY: while ($times < $app_time_out) {
                                       print "New Password: ";
                                        $new_pass1 = &noUtil::conInput;
                                        print "Reenter New Password: ";
                                        $new_pass2 = &noUtil::conInput;
                                        if($new_pass1 eq $new_pass2) {
                                                last PASSENTRY;
                                        }
                                        print "Passwords do not match! Please retry!\n";
                                        $times++;
                                }
                                if($times < $app_time_out) {
                                        my $temp = 0, $flag = 1;
                                        OTHERENTRIES: while ($temp ne $flag) {
                                                print "Enter home directory (blank will default to '$name'):";
                                                $new_home = &noUtil::conInput;
                                                my $test = length $new_home;
                                                #print "$test length\n";
                                                if($test < 1) {$new_home = $name;}

                                                print "New user: '$name' with passwd '$new_pass1'\n";
                                                print "with home '$new_home'\n";
                                                print "Is this correct? (Y/n):";
                                                my $yn = &noUtil::conInput;
                                                if($yn eq "N" || $yn eq "n") {
                                                        $temp = $flag - 1;
                                                } else {
                                                        $temp = $flag;
                                                        last OTHERENTRIES;
                                                }
                                        }
                                        $n2->adduser( -username => $name, -password => $new_pass1,
                                                      -verify => $new_pass2, -home => $new_home );
                                } else {
                                        print "Timed out! Skipping user '$name'!\n";
                                }
                        } else {
                                print "Sorry, cannot add the user '$name': User already exists!\n";
                        }
                }
        } else {
                print "Please enter at least one user name!\n";
        }
}

# Password change dialog
sub passwd {
        my @unames = @_;
        my $new_pass1;
        my $new_pass2;
        if($#unames eq -1) {
                $unames[0] = $n2->{uname};
        }

        foreach my $name (@unames) {
                if($n2->user_exist($name) eq $Noink2::_ERR_NONE_) {
                        print "Changing password for '$name'\n";
                        my $times = 0;
                        PASSENTRY: while ($times < $app_time_out) {
                                print "New Password: ";
                                $new_pass1 = &noUtil::conInput;
                                print "Reenter New Password: ";
                                $new_pass2 = &noUtil::conInput;
                                if($new_pass1 eq $new_pass2) {
                                        last PASSENTRY;
                                }
                                print "Passwords do not match! Please retry!\n";
                                $times++;
                        }
                        if($times < $app_time_out) {
                                $n2->change_password( -username => $name,
                                                      -password => $new_pass1,
                                                      -verify => $new_pass2);
                        } else {
                                print "Timed out!\n";
                        }
                } else {
                        print "User '$name' does not exist! Skipping...\n";
                }
        }
}

# Main console interface
sub main_console {
        # We shouldn't be here if we didn't already log in
        # if we are here without being authenticated, then
        # we will get lots of errors ;-)
        print "\nType 'help' for command help\n";
        CONSOLE: while (1 eq 1) {
                print ":\$ ";
                my $input = &noUtil::conInput;
                my @input_line = split(/ /, $input);
                INPUTPARSE: while($#input_line > -1) {
                        my $cmd = shift(@input_line);
                        if($cmd eq "help") {
                                &show_help(@input_line);
                                last INPUTPARSE;
                        } elsif($cmd eq "quit") {
                                foreach my $test (@input_line) {
                                        if($test eq "-f") {
                                                last CONSOLE;
                                        }
                                }
                                print "Exit, are you sure (y/N)?";
                                my $test = &noUtil::conInput;
                                if($test eq "y" || $test eq "Y") {
                                        last CONSOLE;
                                } else {
                                        last INPUTPARSE;
                                }
                        } elsif($cmd eq "passwd") {
                                &passwd(@input_line);
                                last INPUTPARSE;
                        } elsif($cmd eq "adduser") {
                                &adduser(@input_line);
                                last INPUTPARSE;
                        } elsif($cmd eq "deluser") {
                                &deluser(@input_line);
                                last INPUTPARSE;
                        } elsif($cmd eq "lsuser") {
                                &lsuser(@input_line);
                                last INPUTPARSE;
                        } elsif($cmd eq "addgroup") {
                                &addgroup(@input_line);
                                last INPUTPARSE;
                        } else {
                                print "Command '$cmd' not found\n";
                                last INPUTPARSE;
                        }
                }
        }
}
