'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from types import IntType, StringTypes

from noink import mainDB, mainCrypt, loginManager
from noink.data_models import User, Group, GroupMapping
from noink.event_log import EventLog

from noink.exceptions import DuplicateUser, DuplicateGroup, UserNotFound

from flask.ext.login import login_user

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

    def get_user(self, uid):
        '''
        Given a user id, returns the user object

        @param uid: Integer user id.

        @return the user objects found
        '''
        return User.query.filter_by(id=uid)

    def add(self, username, password, fullname, bio=""):
        '''
        Adds a user to the database.

        @param username: The username to add, must be unique.
        @param password: The password to use.
        @param fullname: The user's full name
        @param bio: The user's bio (optional)

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
        user = u
        if type(u) is IntType:
            user = User.query.filter_by(id=u).first()
        elif type(u) is StringType:
            user = User.query.filter_by(name=u).first()

        group = g
        if type(g) is IntType:
            group = Group.query.filter_by(id=g).first()
        elif type(g) is StringType:
            group = Group.query.filter_by(name=g).first()

        exist = GroupMapping.query.filter_by(user=user).filter_by(group=group).all()

        if exists == []:
            gm = GroupMapping(group, user)
            mainDB.session.add(gm)

        mainDB.session.commit()

    def in_group(self, u, g):
        '''
        Checks if a user is in a group

        @param u: The user to link. Can be an integer for the uid or a user
                  object
        @param g: The group to link. Can be an integer for the gid, a string for
                  group name, or a group object
        '''
        user = u
        if type(u) is IntType:
            user = User.query.filter_by(id=u).first()
        elif type(u) is StringType:
            user = User.query.filter_by(name=u).first()

        group = g
        if type(g) is IntType:
            group = Group.query.filter_by(id=g).first()
        elif type(g) is StringType:
            group = Group.query.filter_by(name=g).first()

        exist = GroupMapping.query.filter_by(user=user).filter_by(group=group).first()

        if exists is None:
            return False

        return True

    def delete(self, u):
        '''
        Deletes a user from the database.

        @param u: A user to delete. Can be an integer for the uid or a user
                  object
        '''

        user = u
        if type(u) is IntType:
            user = User.query.filter_by(id=u).first()
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
            u = self.find_user_by_name(username)[0]
            if mainCrypt.check_password_hash(u.passhash, passwd):
                u.authenticated = True
                u.active = True
                return login_user(u, remember=remember)
            else:
                u.authenticated = False
                u.active = False
                return False
        except: # FIXME - may want better handling
            raise
            return False

@loginManager.user_loader
def _user_load(uid):
    # FIXME - need try here?
    u = UserDB()
    return u.get_user(int(uid))[0]