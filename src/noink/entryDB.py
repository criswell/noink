'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from types import IntType, StringType

from noink import mainDB
from noink.dataModels import Entry
from noink.pickler import PEntry, pickle, depickle
from noink.eventLog import EventLog
from noink.exceptions import DuplicateURL

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
            from noink.urlDB import UrlDB
            self.urlDB = UrlDB()

    def add(self, title, entry, author, url=None):
        '''
        Adds an entry to the system.

        Will not perform any checks, it will just add this entry. It's not
        this method's responsibility to check whether or not your entry is a
        duplicate. The one check it does do is to verify whether a URL is
        unique or not.

        @param title: The title of the post.
        @param entry: The entry of the post.
        @param author: The user object for the post's author
        @param url: The (optional) URL for this post.

        @return New entry object just added
        '''

        now = datetime.datetime.now()

        e = Entry(title, author, now, entry)
        u = None

        if type(url) is StringType:
            if self.urlDB.findByName(url):
                raise DuplicateURL('The URL "%s" was already found in the UrlDB!' % url)
            else:
                mainDB.session.add(e)
                mainDB.session.commit()
                u = self.urlDB.add(url, e)
        else:
            mainDB.session.add(e)
            mainDB.session.commit()

        pe = PEntry(e, u)
        self.eventLog.add('add_entry', author.id, False, pickle(pe), entry.title)
        return e

    def findByTitle(self, title):
        '''
        Finds entries based upon the title. Can search using sub-strings.

        @param title: The title of the post (or sub-string of title).

        @return Array containing one or more entry objects, or None.
        '''
        return Entry.query.filter(Entry.Entry.title.like("%%%s%%" % title)).all()

    def findById(self, num):
        '''
        Finds entries based upon the ID.

        @param num: The numerical ID of the post.

        @return The entry objects, or None.
        '''
        return Entry.query(Entry).get(num)

    def delete(self, e):
        '''
        Deletes an entry from the database.

        @param e: An entry to delete. Can be an integer for the entry id or an
                  entry object.
        '''
        entry = e
        if type(e) is IntType:
            entry = Entry.query.filter_by(id=e).first()

        url = self.urlDB.findByEntry(e)
        pe = PEntry(e, url)
        if url:
            self.urlDB.delete(url)
        mainDB.session.delete(entry)
        mainDB.session.commit()
        self.eventLog.add('del_entry', 0, False, pickle(pe), entry.title)

