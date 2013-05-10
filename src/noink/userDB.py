'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from types import IntType

from noink import mainDB, mainCrypt
from noink.dataModels import User, Group, GroupMapping
from noink.eventLog import EventLog

from noink.exceptions import DuplicateUser, DuplicateGroup, UserNotFound

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

    def findUserByName(self, username):
        '''
        Finds a user by their username

        @param username: The username to find.

        @return The user objects found
        '''
        return User.query.filter_by(name=username).all()

    def findUserById(self, uid):
        '''
        Finds a user by their user ID.

        @param uid: The user's ID to find.

        @return The user object found
        '''
        return User.query.get(uid)

    def getUser(self, uid):
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
            exists = self.findUserByName(username)
        except:
            exists = False

        if exists:
            raise DuplicateUser("%s already exists in database with id '%s'" % (username, str(exists)))
        else:
            passHash = mainCrypt.generate_password_hash(password)
            u = User(username, passHash, fullname, bio)
            mainDB.session.add(u)
            mainDB.session.commit()
            self.eventLog.add('add_user', u.id, True, None, username)
            return u

    def addGroup(self, groupName, userId=None):
        '''
        Adds a new grou to the database.

        @param groupName: The group name to add, must be unique.
        @param userId: (Optional) Single or multiple user IDs to associate with this group.

        @return The group object created
        '''

        exists = Group.query.filter_by(name=groupName).first()

        if exists:
            raise DuplicateGroup("%s already exists in database with id '%s'" % (groupName, exists.id))
        else:
            g = Group(groupName)
            mainDB.session.add(g)
            mainDB.session.flush()
            if userId:
                exists = User.query.filter_by(id=userId).first()
                if exists:
                    gm = GroupMapping(g, exists)
                    mainDB.session.add(gm)
                else:
                    raise UserNotFound("%s not found in database to match with new group" % userId)

            mainDB.session.commit()
            self.eventLog.add('add_group', 0, True, None, groupName)
            return g

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

