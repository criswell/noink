'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from types import IntType

from noink import mainDB, mainCrypt, loginManager, mainApp
from noink.data_models import User, Group, GroupMapping
from noink.event_log import EventLog
from noink.exceptions import (DuplicateUser, DuplicateGroup, UserNotFound,
    UserHasNoGroups, CannotRemovePrimaryGroup, UserNotInGroup)
from noink.util import string_types

from flask.ext.login import login_user, logout_user

class UserDB:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        try:
            self._setup
        except AttributeError:
            self._setup = False

        if not self._setup:
            self.eventLog = EventLog()
            self._setup = True

    def find_user_by_name(self, username):
        '''
        Finds a user by their username

        @param username: The username to find.

        @return The user objects found
        '''
        return User.query.filter_by(name=username).all()

    def find_user_by_id(self, uid):
        '''
        Finds a user by their user ID.

        @param uid: The user's ID to find.

        @return The user object found
        '''
        return User.query.get(uid)

    def get_users(self, u):
        '''
        Given user information, returns the user object

        @param u: The user to find. Can be an integer uid, username string, or
                  even a user object.

        @return the user objects found
        '''
        users = [u]
        if isinstance(u,IntType):
            users = [self.find_user_by_id(u)]
        elif isinstance(u, string_types):
            users = self.find_user_by_name(u)

        return users

    def get_user(self, u):
        '''
         Given user information, returns the user object

        @param u: The user to find. Can be an integer uid, username string, or
                  even a user object.

        @return the user object found
        '''
        user = u
        if isinstance(u,IntType):
            user = self.find_user_by_id(u)
        elif isinstance(u, string_types):
            tu = self.find_user_by_name(u)
            if len(tu) > 0:
                user = tu[0]
            else:
                user = None

        return user

    def add(self, username, password, fullname, bio="", group=None):
        '''
        Adds a user to the database.

        @param username: The username to add, must be unique.
        @param password: The password to use.
        @param fullname: The user's full name
        @param bio: The user's bio (optional)
        @param group: The user's primary group (optional)

        @return The user object for the user crated.
        '''
        try:
            exists = self.find_user_by_name(username)
        except:
            exists = False

        if exists:
            raise DuplicateUser("%s already exists in database with id '%s'" % (username, str(exists)))
        else:
            passHash = mainCrypt.generate_password_hash(password)
            u = User(username, fullname, bio, passHash)
            if group is None:
                group = self.get_group(mainApp.config['DEFAULT_GROUP'])
            u.primary_group = group
            mainDB.session.add(u)
            mainDB.session.commit()
            self.eventLog.add('add_user', u.id, True, None, username)
            return u

    def add_group(self, group_name, user_id=None):
        '''
        Adds a new grou to the database.

        @param group_name: The group name to add, must be unique.
        @param user_id: (Optional) Single or multiple user IDs to associate with this group.

        @return The group object created
        '''

        exists = Group.query.filter_by(name=group_name).first()

        if exists:
            raise DuplicateGroup("%s already exists in database with id '%s'" % (group_name, exists.id))
        else:
            g = Group(group_name)
            mainDB.session.add(g)
            mainDB.session.flush()
            if user_id:
                exists = User.query.filter_by(id=user_id).first()
                if exists:
                    gm = GroupMapping(g, exists)
                    mainDB.session.add(gm)
                else:
                    raise UserNotFound("%s not found in database to match with new group" % user_id)

            mainDB.session.commit()
            self.eventLog.add('add_group', 0, True, None, group_name)
            return g

    def add_to_group(self, u, g):
        '''
        Adds a user to a group.

        @param u: The user to link. Can be an integer for the uid or a user
                  object
        @param g: The group to link. Can be an integer for the gid, a string for
                  group name, or a group object
        '''
        user = self.get_user(u)
        group = self.get_group(g)

        exist = GroupMapping.query.filter_by(user=user).filter_by(group=group).all()

        if exist == []:
            gm = GroupMapping(group, user)
            mainDB.session.add(gm)

        mainDB.session.commit()

    def get_group(self, g):
        '''
        Given a group identifier, return the group object.

        @param g: The group to return. Can be an integer for the gid or a string
                  of the group's name.

        @return The group object found, or None.
        '''
        group = g
        if isinstance(g, IntType):
            group = Group.query.filter_by(id=g).first()
        elif isinstance(g, string_types):
            group = Group.query.filter_by(name=g).first()

        return group

    def get_all_groups(self):
        '''
        Return all possible groups.
        '''
        return Group.query.all()

    def get_users_groups(self, u):
        '''
        Given a user identifier, return the groups it is a member of.

        @param u: The user. Can be an integer for the uid, a string for the
                  username, or a user object

        @return A list of groups the user is a member of.
        '''
        user = self.get_user(u)

        gms = GroupMapping.query.filter_by(user=user)

        if gms is None:
            raise UserHasNoGroups("%s does not have any group mappings! Every user should be a member of at least one group!" % user)

        groups = []
        for m in gms:
            groups.append(m.group)

        return groups

    def update_primary(self, u, g):
        '''
        Updates the primary group a user belongs to. If the user is not already
        in that group, they are added to it.

        @param u: The user to update. Can be an integer for the uid, a username,
                  or a user object
        @param g: The group to use. Can be an integer for the gid, a group name,
                  or a group object.

        @return True on success, False on failure
        '''
        user = self.get_user(u)
        group = self.get_group(g)

        if isinstance(user, User) and isinstance(group, Group):
            exists = GroupMapping.query.filter_by(user=user).filter_by(group=group).first()
            if exists == []:
                self.add_to_group(u, g)
            user.primary_group = group
            mainDB.session.commit()
            return True
        else:
            return False

    def remove_from_group(self, u, g):
        """
        Removes a group association from a user.
        """
        user = self.get_user(u)
        group = self.get_group(g)

        if isinstance(user, User) and isinstance(group, Group):
            if user.primary_group == group:
                raise CannotRemovePrimaryGroup(
                    'Cannot remove {0} from their primary group {1}'.format(
                    user, group))

            gm = GroupMapping.query.filter_by(user=user).filter_by(group=group).first()
            if gm == []:
                raise UserNotInGroup(
                    'User {0} was not a member of the group {1}'.format(
                    user, group))

            mainDB.session.delete(gm)
            mainDB.session.commit()
            self.eventLog.add('rm_from_group', user.id, True, None, user, group)
            return True
        return False

    def update_password(self, u, newpass):
        '''
        Updates the user's password. Assumes that the password has been
        validated.

        @param u: The user to update. Can be an integer for the uid, a username,
                  or a user object.
        @param newpass: The new password.
        '''
        user = self.get_user(u)

        if user is not None:
            user.passhash = mainCrypt.generate_password_hash(newpass)
            mainDB.session.commit()
        else:
            raise UserNotFound("User not found in database")

    def update_user(self, u):
        '''
        Given a user object, update the database with whatever changes it
        contains.

        @param u: A user object.
        '''
        if isinstance(u, User):
            exists = User.query.get(u.id)
            if exists == []:
                mainDB.session.add(u)
            mainDB.session.commit()

    def in_group(self, u, g):
        '''
        Checks if a user is in a group

        @param u: The user to link. Can be an integer for the uid or a user
                  object
        @param g: The group to link. Can be an integer for the gid, a string for
                  group name, or a group object
        '''
        user = self.get_user(u)
        group = self.get_group(g)

        exist = GroupMapping.query.filter_by(user=user).filter_by(group=group).first()

        if exist is None:
            return False

        return True

    def delete(self, u):
        '''
        Deletes a user from the database.

        @param u: A user to delete. Can be an integer for the uid or a user
                  object
        '''

        user = self.get_user(u)
        # FIXME - Need a check here
        uid = int(user.id)
        uname = str(user.name)
        mainDB.session.delete(user)
        mainDB.session.commit()
        self.eventLog.add('del_user', uid, True, None, uname)

    def authenticate(self, username, passwd, remember):
        '''
        Authenticates a user.
        FIXME - docstring
        '''
        try:
            users = self.find_user_by_name(username)
            if len(users) < 1:
                return False
            u = users[0]
            if mainCrypt.check_password_hash(u.passhash, passwd):
                u.authenticated = True
                u.active = True
                mainDB.session.commit()
                return login_user(u, remember=remember)
            else:
                u.authenticated = False
                u.active = False
                mainDB.session.commit()
                return False
        except: # FIXME - may want better handling
            raise
            return False

    def logout(self, u):
        '''
        Given a user, will log them out. Returns True on success, False on failure.

        @param u: A user to logout. Can be a uid or a user object.
        '''
        user = self.get_user(u)
        if u.authenticated or u.active:
            u.authenticated = False
            u.active = False
            mainDB.session.commit()
            logout_user()
            return True
        else:
            logout_user()
            return False

@loginManager.user_loader
def _user_load(uid):
    # FIXME - need try here?
    u = UserDB()
    return u.get_user(int(uid))

