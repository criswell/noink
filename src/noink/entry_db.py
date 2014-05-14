'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from types import IntType, StringType

from noink import mainDB
from noink.data_models import Entry, Tag, TagMapping, Editor
from noink.pickler import PEntry, pickle
from noink.event_log import EventLog
from noink.exceptions import DuplicateURL
from noink.user_db import UserDB

class EntryDB:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        try:
            self._setup
        except AttributeError:
            self._setup = False

        if not self._setup:
            self.event_log = EventLog()
            self._setup = True

    def add(self, title, entry, author, group=None, weight=0, url=None,
            html=False, parent=None, static=False):
        """
        Adds an entry to the system.

        Will not perform any checks, it will just add this entry. It's not
        this method's responsibility to check whether or not your entry is a
        duplicate. The one check it does do is to verify whether a URL is
        unique or not.

        @param title: The title of the post.
        @param entry: The entry of the post.
        @param author: The user object for the post's author
        @param group: The (optional) group this post will belong to. If None,
                      use the author's primary group
        @param url: The (optional) URL for this post.
        @param html: Flag detailing whether this post is in HTML or not
        @param parent: The (optional) parent for this post.
        @param static: (Optional) Whether or not the post is static.

        @return New entry object just added
        """

        now = datetime.datetime.now()

        if group is None:
            group = author.primary_group

        e = Entry(title, author, group, now, entry, weight, url, html, parent,
                static)

        if type(url) is StringType:
            if self.find_by_URL(url):
                raise DuplicateURL(
                        'The URL "%s" was already found in the UrlDB!' % url)
            else:
                mainDB.session.add(e)
                mainDB.session.commit()
        else:
            mainDB.session.add(e)
            mainDB.session.commit()

        pe = PEntry(e)
        self.event_log.add('add_entry', author.id, False, pickle(pe), e.title)
        return e

    def add_entry_object(self, entry):
        """
        Given an entry object, add it to the system.

        @param entry: The entry object to add.
        """
        mainDB.session.add(entry)
        mainDB.session.commit()
        pe = PEntry(entry)
        self.event_log.add('add_entry', entry.author.id, False, pickle(pe),
            entry.title)

    def update_entry(self, entry):
        """
        Given an entry object, update it.

        @param entry: The entry object to update.
        """
        mainDB.session.commit()
        pe = PEntry(entry)
        import ipdb; ipdb.set_trace()
        self.event_log.add('update_entry', entry.author.id, False, pickle(pe),
            entry.title)

    def create_temp_entry(self, title, entry, author, group=None, weight=0,
            url=None, html=False, parent=None, static=False):
        '''
        Create a temporary entry object. Will not add it to the database.

        Will not perform any checks, it will just add this entry. It's not
        this method's responsibility to check whether or not your entry is a
        duplicate. The one check it does do is to verify whether a URL is
        unique or not.

        @param title: The title of the post.
        @param entry: The entry of the post.
        @param author: The user object for the post's author
        @param group: The (optional) group this post will belong to. If None,
                      use the author's primary group
        @param url: The (optional) URL for this post.
        @param html: Flag detailing whether this post is in HTML or not
        @param parent: The (optional) parent for this post.
        @param static: (Optional) Whether or not the post is static.

        @return New entry object
        '''
        now = datetime.datetime.now()

        if group is None:
            group = author.primary_group

        e = Entry(title, author, group, now, entry, weight, url, html, parent,
                static)

        if type(url) is StringType:
            if self.find_by_URL(url):
                raise DuplicateURL(
                        'The URL "%s" was already found in the UrlDB!' % url)

        return e

    def add_tag(self, tags, entry):
        '''
        Adds one or more tags to be associated with an entry. Or, if tags
        already exist, updates them to also point to the entry.

        @param tags: Array of one or more tags.
        @param entry: An entry to associate with the tags.
        '''
        for tag in tags:
            if tag != '':
                t = Tag.query.filter_by(tag=tag).first()
                if t == None:
                    t = Tag(tag)
                    mainDB.session.add(t)
                    self.event_log.add('add_tag', entry.author_id, False, tag,
                        tag)
                exist = TagMapping.query.filter_by(tag_id=t.id).filter_by(
                    entry_id=entry.id).all()
                if exist == []:
                    tm = TagMapping(t, entry)
                    mainDB.session.add(tm)

        mainDB.session.commit()
        tags = self.find_tags_by_entry(entry)

    def update_editor(self, u, e):
        '''
        Given a user and an entry, update that entry's editors with that user.

        @param u: The user who edited the entry. Can be a user object, a uid,
                  or a string representing the username.
        @param e: The entry. Can be an entry id or an entry object.
        '''
        now = datetime.datetime.now()
        entry = e
        if type(e) is IntType:
            entry = Entry.query.filter_by(id=e).first()

        users = UserDB().get_users(u)
        if len(users) > 0:
            user = users[0]
            editor = Editor.query.filter_by(entry_id=e.id).filter_by(
                user_id=user.id).first()
            if editor is None:
                editor = Editor(user, entry, now)
                mainDB.session.add(editor)
            else:
                editor.date = now

            mainDB.session.commit()
            pe = PEntry(entry)
            self.event_log.add('update_entry', user.id, False, pickle(
                pe), entry.title)

    def find_editors_by_entry(self, entry):
        '''
        Given an entry, find all editors associated with it.

        @param entry: The entry. Either an Entry object or entry id.

        @return Array containing zero or more editors.
        '''
        eid = entry
        if type(entry) is not IntType:
            eid = entry.id

        return Editor.query.filter_by(entry_id=eid).all()

    def find_by_URL(self, url):
        """
        Given a URL, find all entries associated with it.

        @param url: The URL string.

        @return Array containing one or more entries.
        """
        return Entry.query.filter_by(url=url).all()

    def find_tags_by_entry(self, entry):
        '''
        Given an entry, find all tags associated with it.

        @param entry: The entry. Either an Entry object or entry id.

        @return Array containing one or more tag objects.
        '''
        e = entry
        if type(entry) is IntType:
            e = self.find_by_id(entry)
        tags = []
        for tm in TagMapping.query.filter_by(entry_id=e.id).all():
            tags.append(tm.tag)

        return tags

    def find_by_tags(self, tags):
        """
        Given one or more tags, find all entries tagged with them.

        @param tags: One or more tags. Tags can be tag ids, tag objects, or
                     tag strings. Tags must be iterable.

        @return Array contating the entry objects.
        """
        # FIXME - The following should order them by weight and date, instead
        # it will cluster them first by tags.
        e = []
        clauses = []
        for tag in tags:
            tagObj = tag
            if type(tag) is IntType:
                tagObj = Tag.query.filter_by(id=tag).first()
            elif type(tag) is StringType:
                tagObj = Tag.query.filter_by(tag=tag).first()
            if tagObj != None:
                clauses.append(TagMapping.tag == tagObj)

        # Yeah, double loops is bad
        if len(clauses) > 0:
            where = mainDB.or_(*clauses)
            # XXX - Is this the best way to do this?
            for mapping in TagMapping.query.filter(where).join(Entry).order_by(
                    Entry.weight).order_by(Entry.date).all():
                e.append(Entry.query.get(mapping.entry_id))

        return e

    def find_recent_by_num(self, num, offset=0, weight=True):
        '''
        Finds the most recent entries with a maximum of 'num'.

        @param num: The number of entries to find
        @param offset: The offset for the entries to find.
        @param weight: If the weight should be taken into account (defaults to
                       true.

        @return Array containing the entry objects.
        '''
        if type(num) is IntType:
            if weight:
                return Entry.query.order_by(Entry.date.desc(),
                        Entry.weight).offset(offset).limit(num).all()
            else:
                return Entry.query.order_by(Entry.date.desc()).offset(
                        offset).limit(num).all()
        else:
            raise TypeError("Expected integer for num")

    def count(self):
        '''
        Returns the number of possible entries.
        '''
        return Entry.query.order_by(Entry.date.desc(), Entry.weight).count()

    def find_by_title(self, title):
        '''
        Finds entries based upon the title. Can search using sub-strings.

        @param title: The title of the post (or sub-string of title).

        @return Array containing one or more entry objects, or None.
        '''
        return Entry.query.filter(Entry.Entry.title.like("%%%s%%" %
            title)).all()

    def find_by_id(self, num):
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
        # FIXME
        # Should deal with parents and children so as not to leave orphans
        entry = e
        if type(e) is IntType:
            entry = Entry.query.filter_by(id=e).first()

        pe = PEntry(e)
        mainDB.session.delete(entry)
        mainDB.session.commit()
        self.event_log.add('del_entry', 0, False, pickle(pe), entry.title)

