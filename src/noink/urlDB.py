'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from types import IntType, StringType

from noink import mainDB
from noink.dataModels import URL
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
            self._setup = True
            from noink.entryDB import EntryDB
            self.entryDB = EntryDB()

    def add(self, name, entry):
        '''
        Adds an URL to the system and associates it with an entry.

        @param name: The URL of the post.
        @param entry: The entry itself. Can be an entry ID or an entry object.

        @return New URL object just added
        '''

        e = entry
        if type(entry) is IntType:
            e = self.entryDB.findById(entry)

        if e:
            u = URL(name, e)
            mainDB.session.add(u)
            mainDB.session.commit()

            self.eventLog.add('add_url', e.author_id, False, str(u.id), (name, e.id))
            return u
        else:
            raise EntryNotFound('The entry could not be found! Entry "%e"' % e)

    def findByName(self, url):
        '''
        Attempts to find a URL by the name.

        @param url: The URL to find.

        @rerturn The URL object or None on failure.
        '''

        return URL.query.filter_by(name=url).first()

    def findByEntry(self, e):
        '''
        Attempts to find a URL by an entry given.

        @param e: The entry. Can either be an entry id or and entry object.

        @return The URL object or None on failure.
        '''
        if type(e) is IntType:
            return URL.query.filter_by(entry_id=e).first()
        return URL.query.filter_by(entry_id=e.id).first()

    def delete(self, u):
        '''
        Deletes an entry from the database.

        @param u: A url to delete. Can be an integer for the URL id or a URL
                  object.
        '''
        url = u
        if type(u) is IntType:
            url = URL.query.filter_by(id=u).first()
        uid = int(u.entry.author_id)
        name = str(u.name)
        mainDB.session.delete(url)
        mainDB.session.commit()
        self.eventLog.add('del_url', uid, False, name, name)
