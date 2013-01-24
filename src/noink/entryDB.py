'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from noink import mainDB
from noink.dataModels import Entry
from noink.eventLog import EventLog

class EntryDB:
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

    def add(self, title, entry, author):
        '''
        Adds an entry to the system.

        Will not perform any checks, it will just add this entry. It's not
        this method's responsibility to check whether or not your entry is a
        duplicate.

        @param title: The title of the post.
        @param entry: The entry of the post.
        @param author: The user object for the post's author

        @return New entry object just added
        '''

        now = datetime.datetime.now()

        e = Entry(title, author, now, entry)
        mainDB.session.add(e)
        mainDB.session.commit()

        self.eventLog.add('add_entry', author.id, False, entry.title)
        return e

