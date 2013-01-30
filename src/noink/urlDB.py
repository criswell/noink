'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from types import IntType, StringType

from noink import mainDB
from noink.dataModels import URL
from noink.entryDB import EntryDB
from noink.eventLog import EventLog
from noink.exceptions import EntryNotFound

class UrlDB:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        try:
            self._setup
        except AttributeError:
            self._setup = False

        if not self._setup:
            self.eventLog = EventLog()
            self.entryDB = EntryDB()
            self._setup = True

    def add(self, name, entry):
        '''
        Adds an URL to the system and associates it with an entry.

        @param name: The URL of the post.
        @param entry: The entry itself. Can be an entry ID or an entry object.

        @returns New URL object just added
        '''

        e = entry
        if type(entry) is IntType:
            e = self.entryDB.findById(entry)

        if e:
            u = URL(name, e)
            mainDB.session.add(u)
            mainDB.session.commit()

            self.eventLog.add('add_url', e.author_id, True, (name, e.id))
            return u
        else:
            raise EntryNotFound('The entry could not be found! Entry "%e"' % e)
