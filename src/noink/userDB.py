'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from noink import mainDB
from noink.dataModels import User, Group, GroupMapping
from noink.eventLog import EventLog

class DuplicateUser(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class UserDB:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        self.eventLog = EventLog()

    def add(self, username, fullname, bio=""):
        '''
        Adds a user to the database.

        @param username: The username to add, must be unique.
        @param fullname: The user's full name
        @param bio: The user's bio (optional)
        '''
        exists = User.query.filter_by(name=username).first()

        if exists:
            raise DuplicateUser("%s already exists in database with id '%d'" % (username, exists.id))
        else:
            u = User(username, fullname, bio)
            mainDB.session.add(u)
            mainDB.session.commit()
            self.eventLog.add('add_user', u.id, True, username)


