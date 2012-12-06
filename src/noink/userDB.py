'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from types import IntType

from noink import mainDB
from noink.dataModels import User, Group, GroupMapping
from noink.eventLog import EventLog

from noink.exceptions import DuplicateUser, DuplicateGroup, UserNotFound

class UserDB:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        if not self._setup:
            self.eventLog = EventLog()
            self._setup = True

    def add(self, username, fullname, bio=""):
        '''
        Adds a user to the database.

        @param username: The username to add, must be unique.
        @param fullname: The user's full name
        @param bio: The user's bio (optional)

        @return The user id for the user crated.
        '''
        exists = User.query.filter_by(name=username).first()

        if exists:
            raise DuplicateUser("%s already exists in database with id '%d'" % (username, exists.id))
        else:
            u = User(username, fullname, bio)
            mainDB.session.add(u)
            mainDB.session.commit()
            self.eventLog.add('add_user', u.id, True, username)
            return u.id

    def addGroup(self, groupName, userId=None):
        '''
        Adds a new grou to the database.

        @param groupName: The group name to add, must be unique.
        @param userId: (Optional) Single or multiple user IDs to associate with this group.
        '''

        exists = Group.query.filter_by(name=groupName).first()

        if exists:
            raise DuplicateGroup("%s already exists in database with id '%s'" % (groupName, exists.id))
        else:
            g = Group(groupName)
            mainDB.session.add(g)
            if userId:
                exists = User.query.filter_by(id=userId).first()
                if exists:
                    gm = GroupMapping(g.id, userId)
                    mainDB.session.add(gm)
                else:
                    raise UserNotFound("%s not found in database to match with new group" % userId)

            mainDB.session.commit()
            self.eventLog.add('add_group', (groupName))

    def del(self, u):
        '''
        Deletes a user from the database.

        @param u: A user to delete. Can be an integer for the uid or a user
                  object
        '''

        user = u
        if type(u) is IntType:
            user = User.query.filter_by(id=u).first()
         mainDB.session.delete(user)
         mainDB.session.commit()

