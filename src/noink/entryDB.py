'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from types import IntType, StringType, ListType

from noink import mainDB
from noink.dataModels import Entry, Tag, TagMapping
from noink.pickler import PEntry, pickle, depickle
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

    def add(self, title, entry, author, weight=0, url=None, html=False):
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

        e = Entry(title, author, now, entry, weight, url, html)

        if type(url) is StringType:
            if self.findByURL(url):
                raise DuplicateURL('The URL "%s" was already found in the UrlDB!' % url)
            else:
                mainDB.session.add(e)
                mainDB.session.commit()
        else:
            mainDB.session.add(e)
            mainDB.session.commit()

        pe = PEntry(e)
        self.eventLog.add('add_entry', author.id, False, pickle(pe), entry.title)
        return e

    def addTag(self, tags, entry):
        '''
        Adds one or more tags to be associated with an entry. Or, if tags
        already exist, updates them to also point to the entry.

        @param tags: Array of one or more tags.
        @param entry: An entry to associate with the tags.
        '''
        for tag in tags:
            t = Tag.query.filter_by(tag=tag).first()
            if t == None:
                t = Tag(tag)
                mainDB.session.add(t)
                self.eventLog.add('add_tag', entry.author_id, False, tag, tag)
            exist = TagMapping.query.filter_by(tag_id=t.id).all()
            if exist == []:
                print "Adding tm"
                tm = TagMapping(t, entry)
                mainDB.session.add(tm)
                print tm

        mainDB.session.commit()
        tags = self.findTagsByEntry(entry)
        print "The tags are:::"
        for tag in tags:
            print tag

    def findByURL(self, url):
        """
        Given a URL, find all entries associated with it.

        @param url: The URL string.

        @return Array containing one or more entries.
        """
        return Entry.query.filter_by(url=url).all()

    def findTagsByEntry(self, entry):
        '''
        Given an entry, find all tags associated with it.

        @param entry: The entry. Either an Entry object or entry id.

        @return Array containing one or more tag objects.
        '''
        e = entry
        if type(entry) is IntType:
            e = self.findById(entry)
        tags = []
        for tm in TagMapping.query.filter_by(entry_id=e.id).all():
            tags.append(tm.tag)

        return tags

    def findByTags(self, tags):
        '''
        Given one or more tags, find all entries tagged with them.

        @param tags: One or more tags. Tags can be tag ids, tag objects, or
                     tag strings. Tags must be iterable.

        @return Array contating the entry objects.
        '''
        e = []
        for tag in tags:
            tagObj = tag
            if type(tag) is IntType:
                tagObj = Tag.query.filter_by(id=tag).first()
            elif type(tag) is StringType:
                tagObj = Tag.query.filter_by(tag=tag).first()

            if tagObj != None:
                for mapping in TagMapping.query.filter_by(tagObj.id).oder_by(Entry.weight, Entry.date):
                    e = e + mapping.entry

        return e

    def findRecentByNum(self, num, weight=True):
        '''
        Finds the most recent entries with a maximum of 'num'.

        @param num: The number of entries to find
        @param weight: If the weight should be taken into account (defaults to
                       true.

        @return Array containing the entry objects.
        '''
        if type(num) is IntType:
            if weight:
                return Entry.query.order_by(Entry.date, Entry.weight).limit(num).all()
            else:
                return Entry.query.order_by(Entry.date).limit(num).all()
        else:
            raise TypeError("Expected integer for num")

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
        return Entry.query.get(num)

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

