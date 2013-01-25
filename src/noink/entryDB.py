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

    def findByTitle(self, title):
        '''
        Finds entries based upon the title. Can search using sub-strings.

        @param title: The title of the post (or sub-string of title).

        @return Array containing one or more entry objects, or None.
        '''
        return Entry.query.filter(Entry.Entry.title.like("%%%s%%" % title)).all()

    def delete(self, e):
        '''
        Deletes an entry from the database.

        @param e: An entry to delete. Can be an integer for the entry id or an
                  entry object.
        '''

        entry = e
        if type(e) is IntType:
            entry = Entry.query.filter_by(id=e).first()
        mainDB.session.delete(e)
        mainDB.session.commit()

