#!/usr/bin/perl -w
# Noink2.pm
package Noink2;

# --------
# Contains the various standard subroutines for Noink2
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

$Noink2::version = '1.9.0';
$Noink2::id = 'Noink2';
$Noink2::name = 'Noink2 core library';
$Noink2::author = 'Samuel Hart <criswell(at)geekcomix(dot)com>';
$Noink2::copyright = '(c) 2002 under the GPL';

# Error severity
# The following are enumerations of errors

# Warning
$Noink2::_ERR_WARN_ = 1;
# Stop (stop Noink2, possibly not addon app)
$Noink2::_ERR_STOP_ = 2;
# Kill (stop Noink2 as well as addon app)
$Noink2::_ERR_KILL_ = 9;
# No error
$Noink2::_ERR_NONE_ = 0;

#Last errors for debugging purposes
@Noink2::last_err = (0);

# Application Types
# HTML (WWW-based)
$Noink2::_TYPE_HTML_ = 1;
# Plain-text
$Noink2::_TYPE_PLAINTEXT_ = 2;
# Call-back
$Noink2::_TYPE_CALLBACK_ = 3;

# Preset Parameters
$Noink2::_DEFAULT_ = 0;
$Noink2::_EXTENDED_ = 1;

# Load Noink2 configuration file
$Noink2::cfgName = 'Noink2-cfg.pl';
do $Noink2::cfgName or die "Unable to load or parse $Noink2::cfgName!";

#====================PRIVATE METHODS! REALLY DO NOT CALL!

sub _self_or_default {
    return @_ if defined($_[0]) && (!ref($_[0])) &&($_[0] eq $Noink2::id);
    unless (defined($_[0]) &&
	    (ref($_[0]) eq $Noink2::id || UNIVERSAL::isa($_[0], $Noink2::id)) # slightly optimized for common case
	    ) {
	$Q = $Noink2->new unless defined($Q);
	unshift(@_,$Q);
    }
    return wantarray ? @_ : $Q;
}

# -----
# _rearrange : borrowed from Lincoln D. Stein's CGI perl module,
#              see accompanying COPYRIGHT document for more info
# Smart rearrangement of parameters to allow named parameter
# calling.  We do the rearangement if:
# the first parameter begins with a -
sub _rearrange {
    my($order,@param) = @_;
    #print "blah\n";
    #foreach $h (@param) {
    #    print "$h\n";
    #}
    return () unless @param;

    if (ref($param[0]) eq 'HASH') {
	@param = %{$param[0]};
    } else {
	return @param
	    unless (defined($param[0]) && substr($param[0],0,1) eq '-');
    }

    # map parameters into positional indices
    my ($i,%pos);
    $i = 0;
    foreach (@$order) {
	foreach (ref($_) eq 'ARRAY' ? @$_ : $_) { $pos{lc($_)} = $i; }
	$i++;
    }

    my (@result,%leftover);
    $#result = $#$order;  # preextend
    while (@param) {
	my $key = lc(shift(@param));
	$key =~ s/^\-//;
	if (exists $pos{$key}) {
	    $result[$pos{$key}] = shift(@param);
	} else {
	    $leftover{$key} = shift(@param);
	}
    }

    push (@result,make_attributes(\%leftover,1)) if %leftover;
    @result;
}

# -----
# _push_error($err_no) : Push an error onto the error queue
sub _push_error {
        my ($err_no, $self) = @_;
        push (@self::last_err, $err_no);

        # By doing the following, once we get more than max_errs, the app will slow down considerably!!
        if($#self::last_err >= $Noink2_cfg::max_errs) {
                shift(@self::last_err);
        }
}

# -----
# _throw_error($text, $err_no) : Throws an error based on output type and returns error given
sub _throw_error {
        my ($text, $err_no, $self) = @_;

        #Stub for now, need to do more later
        if($self->{_app_type} eq $Noink2::_TYPE_PLAINTEXT_) {
                if($err_no > $self->{_app_errorlevel}) {
                        # Only display these if they are necessary
                        print $text;
                        print "\n";
                }
        }
        _push_error($err_no, $self);
        return $err_no;
}

# -----
# _create_passfile : Create a password file
sub _create_passfile {
        my $self = @_;
        #Only create the passfile if it's not already there!
        my $pfile = "${Noink2_cfg::root_dir}/passwd";
        if(!open(PFILE, $pfile)) {
                if(open(PFILE, ">${pfile}")) {
                        print PFILE "0${Noink2_cfg::_delim_}${Noink2_cfg::admin_id}${Noink2_cfg::_delim_}${Noink2_cfg::admin_pwd}${Noink2_cfg::_delim_}${Noink2_cfg::admin_home}\n";
                        close PFILE;
                } else {
                        return _throw_error("Cannot write password file \"$pfile\"!\nCheck permissions!", $Noink2::_ERR_KILL_, $self);
                }
        } else {
                return _throw_error("Password file \"$pfile\" already exists!\nDelete manually to reset!", $Noink2::_ERR_WARN_, $self);
        }
        return $Noink2::_ERR_NONE_;
}

# ----
# _create_groupfile($self) : Creates the default group file
sub _create_groupfile {
        my ($self) = @_;
        #Only create the groupfile if it's not already there!
        my $gfile = "${Noink2_cfg::root_dir}/groups";
        #print "Creating \'$gfile\"\n";
        if(!open(GFILE, $gfile)) {
                if(open(GFILE, ">${gfile}")) {
                        print GFILE "0${Noink2_cfg::_delim_}${Noink2_cfg::admin_group}${Noink2_cfg::_delim_}0\n";
                        close GFILE;
                } else {
                        return _throw_error("Cannot write group file \"$gfile\"!\nCheck permissions!", $Noink2::_ERR_KIL_, $self);
                }
        } else {
                return _throw_error("Group file \"$gfile\" already exists!\nDelete manually to reset!", $Noink2::_ERR_WARN_, $self);
        }
        return $Noink2::_ERR_NONE_;
}

# -----
# _get_groups ($uid, $self) : Get group affiliations for user
sub _get_groups {
        my ($uid, $self) = @_;
        my $err_no = $Noink2::_ERR_NONE_;
        undef my $found;

        my $gfile = "${Noink2_cfg::root_dir}/groups";
        if(open(GFILE, $gfile)) {
                my @tfile = <GFILE>;
                close GFILE;
                foreach my $temp_line (@tfile) {
                        chomp $temp_line;
                        my ($temp_id, $temp_group, $temp_uids) = split(/${Noink2_cfg::_delim_}/, $temp_line);
                        my @uids = split(/${Noink2_cfg::_delim2_}/, $temp_uids);
                        foreach my $test_uid (@uids) {
                                if($test_uid eq $uid) {
                                        push (@self::gids, $temp_id);
                                        $found = 1;
                                        # Note that for now we have no max number of groups
                                        # an idividual user can be a part of!
                                }
                                if($temp_group eq $self->{_app_group}) {
                                        $self->{_app_gid} = $temp_id;
                                }
                        }
                }

                if( !defined $found ) {
                        $err_no =  _throw_error("User does not appear to belong to any groups!", $Noink2::_ERR_WARN_, $self);
                }
        } else {
                $err_no = _create_groupfile($self);
        }
        return $err_no;
}

#====================PUBLIC METHODS! FEEL FREE TO USE!

#====================CONSTRUCTOR AND DESTRUCTOR
sub new {
        my $self = {};
        undef $self->{UID};
        undef $self->{_app_id};
        undef $self->{_app_gid};
        bless($self);
        return $self;
}

sub DESTROY { }

# ----
# register : Call this to register your application
#  Parameters[
#               -version : (optional)  sets your app's version
#               -id : (required) sets your app's id
#               -group : (required) sets your app's group
#               -name : (optional) sets your app's name
#               -author : (optional) sets your app's author
#               -copyright : (optional) sets your app's copyright
#               -apptype : (optional) sets your app's type
#               -callback : (optional) if your app type is callback, then
#                               set this with the function to callback on output
sub register {
        my($self,@p) = _self_or_default(@_);
        my ($version, $id, $group, $name, $author, $copyright, $app_type, $callback, $errlev, @other) =
          _rearrange([VERSION,ID,GROUP,NAME,AUTHOR,COPYRIGHT, APPTYPE, CALLBACK, ERRORLEVEL],@p);

        $self->{_app_version} = $version;
        #print "$version\n$id\n$name\n$author\n$copyright\n";

        if($id) {
                $self->{_app_id} = $id;
        } else {
                undef $self->{_app_id};
                return _throw_error("Application not properly registered!\nMay not work correctly!", $Noink2::_ERR_WARN_, $self);
        }
        if($group) {
                $self->{_app_group} = $group;
        } else {
                undef $self->{_app_group};
                return _throw_error("Application not properly registered!\nMay not work correctly!", $Noink2::_ERR_WARN_, $self);
        }
        $self->{_app_name} = $name;
        $self->{_app_author} = $author;
        $self->{_app_copyright} = $copyright;
        $self->{_app_type} = $app_type;
        $self->{_app_callback} = $callback;
        if($errlev) {
                $self->{_app_errorlevel} = $errlev;
        } else {
                $self->{_app_errorlevel} = 0;
        }

        #my $self = {};
        #bless($self);
        #return $self;
        return $Noink2::_ERR_NONE_;
}

# ----
# check_group: Checks if the user is member of this apps group
#              returns _ERR_NONE_ if group checks out okay
sub check_group {
        my($self,@p) = _self_or_default(@_);
        #First, we must be logged in and registered
        if(defined $self->{UID} && defined $self->{_app_id} && defined $self->{_app_gid}) {
                foreach my $gid (@self::gids) {
                        if($gid eq $self->{_app_gid}) {
                                return $Noink2::_ERR_NONE_;
                        }
                }
                return _throw_error("User \"$self->{UID}\" not part of group \"$self->{_app_gid}\"!", $Noink2::_ERR_STOP_, $self);
        }
        return _throw_error("User not logged in, application not registered, or some other critical error has occured!", $Noink2::_ERR_STOP_, $self);
}

# ----
# display_header: Displays the header given the app_type
sub display_header {
        my($self, @p) = _self_or_default(@_);

        #Enumerate the types
        if($self->{_app_type} eq $Noink2::_TYPE_HTML_) {
                print $Noink2_cfg::html_header;
        } elsif($self->{_app_type} eq $Noink2::_TYPE_CALLBACK_) {
                # Actually, we really don't do anything here yet
                # FIXME
        } else {
                # Default is plain text
                print $Noink2_cfg::text_header;
        }
}

# ----
# display_footer: Displays the footer given the app_type
sub display_footer {
        my($self, @p) = _self_or_default(@_);

        #Enumerate the types
        if($self->{_app_type} eq $Noink2::_TYPE_HTML_) {
                print $Noink2_cfg::html_footer;
        } elsif($self->{_app_type} eq $Noink2::_TYPE_CALLBACK_) {
                # Actually, we really don't do anything here yet
                # FIXME
        } else {
                # Default is plain text
                print $Noink2_cfg::text_footer;
        }
}

# ----
# authorize: Authorizes the current user. Returns _ERR_NONE_
#            if authorized, _ERR_WARN_ if not authorized,
#            _ERR_STOP_ if not part of a group, or _ERR_KILL_
#            if not logged in, app not registered, or some
#            other critical error.
#  Parameters[ one of the following is required
#               -gid : The group id
#               -group : the group name
sub authorize {
        my($self, @p) = _self_or_default(@_);
        my($gid, $group) = _rearrange([GID,GROUP], @p);

        if(!defined $self->{UID} || $self->{UID} eq -1 ||
           !defined $self->{_app_id} || !defined $self->{_app_gid} ) {
                return _throw_error("User not logged in, app not registered, or some other critical error occured!", $Noink2::_ERR_KILL_, $self);
        }

        if(defined $gid) {
                foreach my $id (@self::gids) {
                        if($id eq $gid) {
                                #Yes, they are a member of this group
                                return $Noink2::_ERR_NONE_;
                        }
                }
                #If we get here, then they must not be a memeber of this group
                return _throw_error("Not a member of this group!", $Noink2::_ERR_WARN_, $self);
        } elsif(defined $group) {
                #FIX ME, need to search group file and compare numbers
        } else {
                return _throw_error("Method option not understood!", $Noink2::_ERR_KILL_, $self);
        }
        return _throw_error("Unknown error calling Noink2->authorize!\nPlease check your code!", $noink2::_ERR_KILL_, $self);
}

# -----
# user_exist: Returns _ERR_NONE_ if user exists, _ERR_WARN_
#             if user does not exist, _ERR_STOP_ if passwd
#             file does not exist, or _ERR_KILL_ if app not
#             registered, user not logged in, or some other
#             critical error
#  Parameter[
#            $username : (required) the username to check on
sub user_exist {
        my($self, @p) = _self_or_default(@_);
        if($#p eq -1) {
                return _throw_error("Method not called correctly!\nMust supply a user login name!", $Noink2::_ERR_KILL_, $self);
        }
        my $found = -1;

        my $pfile = "${Noink2_cfg::root_dir}/passwd";
        if(open(PFILE, $pfile)) {
                my @pasfile = <PFILE>;
                close PFILE;
                foreach my $temp_line (@pasfile) {
                        chomp $temp_line;
                        my ($temp_id, $temp_login, $temp_pass, $temp_path) =
                                split(/${Noink2_cfg::_delim_}/, $temp_line);
                        if($p[0] eq $temp_login) {
                                $found = 1;
                                if($self->{UID} ne $temp_id &&
                                   $self->authorize( -gid => "0" ) ne $Noink2::_ERR_NONE_) {
                                        return _throw_error("Logged in user $self->{uname} does not have permission for this search!", $Noink2::_ERR_KILL_, $self);
                                }
                                last;
                        }
                }
        } else {
                my $errno = _create_passfile($self);
                if ($errno ne $Noink2::_ERR_NONE_) {
                        return $errno;
                } else {
                        return _throw_error("Password file did not exist! Creating default!", $Noink2::_ERR_STOP_, $self);
                }
        }
        if($found ne -1) {
                return $Noink2::_ERR_NONE_;
        } else {
                return _throw_error("User '$p[0]' not found!", $Noink2::_ERR_WARN_, $self);
        }
}

# -----
# group_exist: Returns _ERR_NONE_ if group exists, _ERR_WARN_
#             if group does not exist, _ERR_STOP_ if passwd
#             file does not exist, or _ERR_KILL_ if app not
#             registered, group not logged in, or some other
#             critical error
#  Parameter[
#            $groupname : (required) the group name to check on
sub group_exist {
        my($self, @p) = _self_or_default(@_);
        if($#p eq -1) {
                return _throw_error("Method not called correctly!\nMust supply a group name!", $Noink2::_ERR_KILL_, $self);
        }
        my $found = -1;

        my $gfile = "${Noink2_cfg::root_dir}/groups";
        if(open(PFILE, $gfile)) {
                my @groupfile = <PFILE>;
                close PFILE;
                foreach my $temp_line (@groupfile) {
                        chomp $temp_line;
                        my ($temp_gid, $temp_group, $temp_uids) =
                                split(/${Noink2_cfg::_delim_}/, $temp_line);
                        if($p[0] eq $temp_group) {
                                $found = 1;
                                if($self->{_app_name} ne $temp_group &&
                                   $self->authorize( -gid => "0" ) ne $Noink2::_ERR_NONE_) {
                                        return _throw_error("Logged in user $self->{uname} using app $self->{_app_name} does not have permission for this search!", $Noink2::_ERR_KILL_, $self);
                                }
                                last;
                        }
                }
        } else {
                my $errno = _create_groupfile($self);
                if ($errno ne $Noink2::_ERR_NONE_) {
                        return $errno;
                } else {
                        return _throw_error("Group file did not exist! Creating default!", $Noink2::_ERR_STOP_, $self);
                }
        }
        if($found ne -1) {
                return $Noink2::_ERR_NONE_;
        } else {
                return _throw_error("Group '$p[0]' not found!", $Noink2::_ERR_WARN_, $self);
        }
}

# -----
# get_user_info : Obtains the requested user info.
#                 Will only work if either of the following are true:
#                       A) The logged in user is in admin group
#                       B) The logged in user is the same as the requested info user
#  Parameter[
#               $username : (required) the user name looking for
#  Returns[
#               @info_array : The user info array with following properties
#               $info_array[0] : User ID
#               $info_array[1] : User login name
#               $info_array[2] : user home directory path
#               $info_array[4] : Some error (with following interpretations)
#                       _ERR_NONE_ - No err
#                       _ERR_WARN_ - Not user or insufficient privelages
#                       _ERR_STOP_ - Not logged in
#                       _ERR_KILL_ - App not registered or some other critical
#                                    error
sub get_user_info {
        my($self, @p) = _self_or_default(@_);
        if($#p eq -1) {
                return _throw_error("Method not called correctly!\nMust supply a user login name!", $Noink2::_ERR_KILL_, $self);
        }
        my $found = -1;
        my ($id, $login, $path);

        my $pfile = "${Noink2_cfg::root_dir}/passwd";
        if(open(PFILE, $pfile)) {
                my @pasfile = <PFILE>;
                close PFILE;
                foreach my $temp_line (@pasfile) {
                        chomp $temp_line;
                        my ($temp_id, $temp_login, $temp_pass, $temp_path) =
                                split(/${Noink2_cfg::_delim_}/, $temp_line);
                        if($p[0] eq $temp_login) {
                                $found = 1;
                                $id = $temp_id;
                                $login = $temp_login;
                                $path = $temp_path;
                        }
                }
        }
}

# -----
# lsuser: Returns a list of users or none if not authorized
#  Parameters[
#               -username: (optional) the user name to list
#               -type:     (optional) the type return
sub lsuser {
        my($self, @p) = _self_or_default(@_);
        my($user_name, $type) = _rearrange([USERNAME, TYPE], @p);

        my @lst = ();

        if($type eq $Noink2::_EXTENDED_) {
                push(@lst, "ID\tLOGIN\tPATH");
        }

        #First, let's authorize
        if($self->authorize( -gid => "0" ) eq $Noink2::_ERR_NONE_) {
                # Okay, so load the file
                my $pfile = "${Noink2_cfg::root_dir}/passwd";
                if(open(PFILE, $pfile)) {
                        my @pasfile = <PFILE>;
                        close PFILE;
                        foreach my $line (@pasfile) {
                                chomp $line;
                                my ($temp_id, $temp_login, $temp_pass, $temp_path) =
                                                        split(/${Noink2_cfg::_delim_}/, $line);
                                if($user_name) {
                                        if($user_name eq $temp_login) {
                                                if($type eq $Noink2::_EXTENDED_) {
                                                        push(@lst, "$temp_id\t$temp_login\t$temp_path");
                                                } else {
                                                        push(@lst, "$temp_login");
                                                }
                                        }
                                } else {
                                        if($type eq $Noink2::_EXTENDED_) {
                                                push(@lst, "$temp_id\t$temp_login\t$temp_path");
                                        } else {
                                                push(@lst, "$temp_login");
                                        }
                                }
                        }
                }
        }

        return @lst;
}

# -----
# deluser: Returns _ERR_NONE_ if user deleted successfully.
#         WARNING: DELETES FOR REAL! DON'T USE LIGHTLY!
#  Parameters[
#               -username: (required) the user name to delete
sub deluser {
        my($self, @p) = _self_or_default(@_);
        my($user_name) = _rearrange([USERNAME], @p);

        my $err_no = $Noink2::_ERR_NONE_;

        #First, let's see if user exists (the app-writer should check this, but in case they don't ;-)
        if($self->user_exist($user_name) eq $Noink2::_ERR_NONE_) {
                if($self->authorize( -gid => "0" ) eq $Noink2::_ERR_NONE_) {
                        # Okay, so load the file
                        my $pfile = "${Noink2_cfg::root_dir}/passwd";
                        my $pfile_lock = "${Noink2_cfg::root_dir}/passwd.lock";
                        if(open(PFILE, $pfile)) {
                                my @pasfile = <PFILE>;
                                close PFILE;
                                if(open(PFILE, ">$pfile_lock")) {
                                        foreach my $temp_line (@pasfile) {
                                                chomp $temp_line;
                                                my ($temp_id, $temp_login, $temp_pass, $temp_path) =
                                                        split(/${Noink2_cfg::_delim_}/, $temp_line);
                                                if($user_name ne $temp_login) {
                                                        print PFILE "${temp_id}${Noink2_cfg::_delim_}${temp_login}${Noink2_cfg::_delim_}${temp_pass}${Noink2_cfg::_delim_}${temp_path}\n";
                                                } elsif($temp_id == 0) {
                                                        # We can't delete the administrator! Sorry.
                                                        # I know this is silently failing, and we
                                                        # should really do something about that...
                                                        # FIXME
                                                        print PFILE "${temp_id}${Noink2_cfg::_delim_}${temp_login}${Noink2_cfg::_delim_}${temp_pass}${Noink2_cfg::_delim_}${temp_path}\n";
                                                }
                                        }
                                        close PFILE;

                                        unlink $pfile;
                                        rename $pfile_lock, $pfile;
                                } else {
                                        $err_no = _throw_error("Cannot open passwd.lock file in Noink2_cfg::root_dir! Please check permissions!", $Noink2::_ERR_KILL_, $self);
                                }
                        } else {
                                $err_no = _throw_error("Problem openning password file! Please check permissions and existence!", $Noink2::_ERR_KILL_, $self);
                        }
                } else {
                        $err_no = _throw_error("Not authorized to do deluser (must be admin group!)", $Noink2::_ERR_WARN_, $self);
                }
        } else {
                $err_no = _throw_error("User does not exist!", $Noink2::_ERR_WARN_, $self);
        }
}

# -----
# adduser: Returns _ERR_NONE_ if user added successfully
#  Parameters[
#               -username: (required) the user name to add
#               -password: (required) the new password
#               -verify:   (required) the verified password
#               -home:     (optional) home directory (defayults to user name)
sub adduser {
        my($self,@p) = _self_or_default(@_);
        my ($user_name, $pass1, $pass2, $home) = _rearrange([USERNAME, PASSWORD, VERIFY, HOME], @p);

        my $err_no = $Noink2::_ERR_NONE_;

        #First, let's see if user exists (the app-writer should check this, but in case they don't ;-)
        if($self->user_exist($user_name) ne $Noink2::_ERR_NONE_) {
                #check passwords
                if($pass1 eq $pass2) {
                        # Okay, so load the file
                        my $pfile = "${Noink2_cfg::root_dir}/passwd";
                        my $pfile_lock = "${Noink2_cfg::root_dir}/passwd.lock";
                        if(open(PFILE, $pfile)) {
                                my @pasfile = <PFILE>;
                                close PFILE;
                                if(open(PFILE, ">$pfile_lock")) {
                                        my $new_id = 0;
                                        foreach my $temp_line (@pasfile) {
                                                chomp $temp_line;
                                                my ($temp_id, $temp_login, $temp_pass, $temp_path) =
                                                        split(/${Noink2_cfg::_delim_}/, $temp_line);
                                                if($new_id eq $temp_id) { $new_id++;}
                                                print PFILE "${temp_id}${Noink2_cfg::_delim_}${temp_login}${Noink2_cfg::_delim_}${temp_pass}${Noink2_cfg::_delim_}${temp_path}\n";
                                        }
                                        print PFILE "${new_id}${Noink2_cfg::_delim_}${user_name}${Noink2_cfg::_delim_}${pass1}${Noink2_cfg::_delim_}${home}\n";
                                        close PFILE;

                                        unlink $pfile;
                                        rename $pfile_lock, $pfile;
                                } else {
                                        $err_no = _throw_error("Cannot open passwd.lock file in Noink2_cfg::root_dir! Please check permissions!", $Noink2::_ERR_KILL_, $self);
                                }
                        } else {
                                $err_no = _throw_error("Problem openning password file! Please check permissions and existence!", $Noink2::_ERR_KILL_, $self);
                        }
                } else {
                        $err_no = _throw_error("New passwords do not match!", $Noink2::_ERR_STOP_, $self);
                }
        } else {
                $err_no = _throw_error("User already exists!", $Noink2::_ERR_WARN_, $self);
        }
}

# -----
# addgroup: Returns _ERR_NONE_ if group added successfully
#  Parameters[
#               -groupname: (required) the group name to add
#               -uids:      (optional) optional user IDs to add to this group
sub addgroup {
        my($self,@p) = _self_or_default(@_);
        my ($group_name, $uids) = _rearrange([GROUPNAME, UIDS], @p);

        my $err_no = $Noink2::_ERR_NONE_;

        #First, let's see if group exists (the app-writer should check this, but in case they don't ;-)
        if($self->group_exist($group_name) ne $Noink2::_ERR_NONE_) {
                # Okay, so load the file
                my $gfile = "${Noink2_cfg::root_dir}/groups";
                my $gfile_lock = "${Noink2_cfg::root_dir}/groups.lock";
                if(open(PFILE, $gfile)) {
                        my @groupfile = <PFILE>;
                        close PFILE;
                        if(open(PFILE, ">$gfile_lock")) {
                                my $new_id = 0;
                                foreach my $temp_line (@pasfile) {
                                        chomp $temp_line;
                                        my ($temp_gid, $temp_group, $temp_uids) =
                                                split(/${Noink2_cfg::_delim_}/, $temp_line);
                                        if($new_id eq $temp_gid) { $new_id++;}
                                        print PFILE "${temp_gid}${Noink2_cfg::_delim_}${temp_group}${Noink2_cfg::_delim_}${temp_uids}\n";
                                }
                                print PFILE "${new_id}${Noink2_cfg::_delim_}${group_name}${Noink2_cfg::_delim_}${uids}\n";
                                close PFILE;

                                unlink $gfile;
                                rename $gfile_lock, $gfile;
                        } else {
                                $err_no = _throw_error("Cannot open group.lock file in Noink2_cfg::root_dir! Please check permissions!", $Noink2::_ERR_KILL_, $self);
                        }
                } else {
                        $err_no = _throw_error("Problem openning group file! Please check permissions and existence!", $Noink2::_ERR_KILL_, $self);
                }
        } elsif(defined $uids) {
                # Just add the UIDs
                # Okay, so load the file
                my $gfile = "${Noink2_cfg::root_dir}/groups";
                my $gfile_lock = "${Noink2_cfg::root_dir}/groups.lock";
                if(open(PFILE, $gfile)) {
                        my @groupfile = <PFILE>;
                        close PFILE;
                        if(open(PFILE, ">$gfile_lock")) {
                                foreach my $temp_line (@pasfile) {
                                        chomp $temp_line;
                                        my ($temp_gid, $temp_group, $temp_uids) =
                                                split(/${Noink2_cfg::_delim_}/, $temp_line);
                                        if($temp_group eq $group_name) {
                                                my @split_uids = split(/${Noink2_cfg::_delim2_}/, $temp_uids);
                                                my @split_adduids = split(/${Noink2_cfg::_delim2_}/, $uids);
                                                my @newids = ();
                                                if($#split_uids > -1) {
                                                        # Prevent repeats
                                                        foreach my $ids (@split_uids) {
                                                                foreach my $nids (@split_adduids) {
                                                                        if($ids ne $nids) {
                                                                                push $ids, @new_uids;
                                                                        }
                                                                }
                                                        }
                                                        foreach my $ids (@split_adduids) {
                                                                push $ids, @new_uids;
                                                        }
                                                } else {
                                                        foreach my $ids (@split_adduids) {
                                                                push $ids, @new_uids;
                                                        }
                                                }
                                                join # HERE I AM JH
                                                print PFILE "${temp_gid}${Noink2_cfg::_delim_}${temp_group}${Noink2_cfg::_delim_}${new_uids}\n";
                                        } else {
                                                print PFILE "${temp_gid}${Noink2_cfg::_delim_}${temp_group}${Noink2_cfg::_delim_}${temp_uids}\n";
                                        }
                                }
                                close PFILE;

                                unlink $gfile;
                                rename $gfile_lock, $gfile;
                        } else {
                                $err_no = _throw_error("Cannot open group.lock file in Noink2_cfg::root_dir! Please check permissions!", $Noink2::_ERR_KILL_, $self);
                        }
                } else {
                        $err_no = _throw_error("Problem openning group file! Please check permissions and existence!", $Noink2::_ERR_KILL_, $self);
                }
        } else {
                $err_no = _throw_error("Group already exists! Try with UIDS option to add UIDS!", $Noink2::_ERR_WARN_, $self);
        }
}

# -----
# change_password: Returns _ERR_NONE_ if no error
#  Parameters[
#               -username : (required) the user name to change password for
#               -password : (required) the new password
#               -verify:    (required) the verified password
sub change_password {
        my($self,@p) = _self_or_default(@_);
        my ($user_name, $pass1, $pass2) = _rearrange([USERNAME, PASSWORD, VERIFY], @p);

        my $err_no = $Noink2::_ERR_NONE_;
        my $found = 0;

        # First, let's authenticate the user has permission to do this
        if($user_name eq $self->{uname} || $self->{UID} eq 0) {
                # Next, make sure tha the passwords match
                if($pass1 eq $pass2) {
                        # I guess it checks out, let's update the file
                        my $pfile = "${Noink2_cfg::root_dir}/passwd";
                        my $pfile_lock = "${Noink2_cfg::root_dir}/passwd.lock";
                        if(open(PFILE, $pfile)) {
                                my @pasfile = <PFILE>;
                                close PFILE;
                                if(open(PFILE, ">$pfile_lock")) {
                                        foreach my $temp_line (@pasfile) {
                                                chomp $temp_line;
                                                my ($temp_id, $temp_login, $temp_pass, $temp_path) =
                                                        split(/${Noink2_cfg::_delim_}/, $temp_line);
                                                if($user_name eq $temp_login) {
                                                        $found = 1;
                                                        $temp_pass = $pass1;
                                                }
                                                print PFILE "${temp_id}${Noink2_cfg::_delim_}${temp_login}${Noink2_cfg::_delim_}${temp_pass}${Noink2_cfg::_delim_}${temp_path}\n";
                                        }
                                        close PFILE;
                                        # Remove the original file and replace with locked file
                                        unlink $pfile;
                                        rename $pfile_lock, $pfile;
                                } else {
                                        $err_no = _throw_error("Cannot open passwd.lock file in Noink2_cfg::root_dir! Please check permissions!", $Noink2::_ERR_KILL_, $self);
                                }
                        } else {
                                $err_no = _throw_error("Problem openning password file! Please check permissions and existence!", $Noink2::_ERR_KILL_, $self);
                        }
                } else {
                        $err_no = _throw_error("New passwords do not match!", $Noink2::_ERR_STOP_, $self);
                }
        } else {
                $err_no = _throw_error("User does not have sufficient privelages for this action", $Noink2::_ERR_KILL_, $self);
        }
        return $err_no;
}

# -----
# login_user: RETURNS error and sets UID equal user id
#  Parameters[
#               -username : (required) the requested user name
#               -password : (required) the attempted password
sub login_user {
        my($self,@p) = _self_or_default(@_);
        my ($user_name, $password) = _rearrange([USERNAME, PASSWORD], @p);
        $self->{UID} = -1;

        my $err_no = $Noink2::_ERR_NONE_;

        #Access the password file
        #if( ($user_name eq $Noink2_cfg::admin_id) && ($password eq $Noink2_cfg::admin_pwd) ) {
        #        $self->{UID} = 0;
        #} else {
                my $pfile = "${Noink2_cfg::root_dir}/passwd";
                if(open(PFILE, $pfile)) {
                        my @pasfile = <PFILE>;
                        close PFILE;
                        foreach my $temp_line (@pasfile) {
                                chomp $temp_line;
                                my ($temp_id, $temp_login, $temp_pass, $temp_path) = split(/${Noink2_cfg::_delim_}/, $temp_line);
                                #print "Testing '$temp_login' eq '$user_name'\n";
                                #print "and     '$temp_pass' eq '$password'\n";

                                if( ($temp_login eq $user_name) && ($temp_pass eq $password) ) {
                                        # We're logged in
                                        $self->{uname} = $temp_login;
                                        $self->{UID} = $temp_id;
                                        $self->{path} = $temp_path;
                                        $self->{login} = $temp_login;
                                        # Get group affiliation(s)
                                        $err_no = _get_groups($temp_id, $self);
                                        last; #Nothing to do ;-)
                                }
                        }
                } else {
                        # Need to make the password file
                        $err_no = _create_passfile($self);
                }
        #}
        if($self->{UID} eq -1) {
                #Not logged in
                $err_no = _throw_error("Username or password not correct!", $Noink2::_ERR_STOP_, $self);
        }
        return $err_no;
}

sub test {
        print "Well, I am in the test subroutine\n";
        print "In the package ${Noink2::id} version: ${Noink2::version}\n";
}

END { };
