"""
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
"""

from noink import mainDB

class User(mainDB.Model):
    '''
    Basic user class.

    Currently, we leave authentication and, indeed, user management up to an
    external source. By the time a user hits Noink, we assume they are a real,
    actual user that must be in the database. If they do *not* exist in Noink,
    then we add it.
    '''
    __tablename__ = 'user'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    name = mainDB.Column(mainDB.String(60))
    fullname = mainDB.Column(mainDB.String(80))
    bio = mainDB.Column(mainDB.String(4000))
    passhash = mainDB.Column(mainDB.String(60))

    authenticated = mainDB.Column(mainDB.Boolean)
    active = mainDB.Column(mainDB.Boolean)

    def is_authenticated(self):
        return self.authenticated

    def is_active(self):
        return self.active

    def is_anonymous(self):
        # we kind of assume they will never be anonymous if they come from DB
        return False

    def get_id(self):
        return unicode(self.id)

    def __init__(self, name, fullname, bio, passhash):
        self.name = name
        self.fullname = fullname
        self.bio = bio
        self.passhash = passhash
        self.authenticated = False
        self.active = False

    def __repr__(self):
        return "<User %s, id %s>" % (self.name, self.id)

class Group(mainDB.Model):
    __tablename__ = 'group'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    name = mainDB.Column(mainDB.String(60))

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return "<Group %s, id %s>" % (self.name, self.id)

class GroupMapping(mainDB.Model):
    __tablename__ = 'groupmap'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    group_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("group.id"))
    group = mainDB.relationship('Group')
    user_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("user.id"))
    user = mainDB.relationship("User")

    def __init__(self, group, user):
        self.group = group
        self.user = user

    def __repr__(self):
        return "<Group %s : User %s>" % (self.group, self.user)

class Event(mainDB.Model):
    __tablename__ = 'events'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    event = mainDB.Column(mainDB.String(40))
    description = mainDB.Column(mainDB.String(500))
    date = mainDB.Column(mainDB.DateTime())
    user = mainDB.Column(mainDB.Integer)
    blob = mainDB.Column(mainDB.String(500))
    processed = mainDB.Column(mainDB.Boolean())
    processed_date = mainDB.Column(mainDB.DateTime())


    def __init__(self, event, description, date, user, blob):
        self.event = event
        self.description = description
        self.date = date
        self.user = user
        self.blob = blob

    def __repr__(self):
        return "<Event %s>" % self.event

class Tag(mainDB.Model):
    __tablename__ = 'tags'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    tag = mainDB.Column(mainDB.String(20))

    def __init__(self, tag):
        self.tag = tag

    def __repr__(self):
        return "<Tag %s>" % self.tag

class TagMapping(mainDB.Model):
    __tablename__ = 'tagmap'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    tag_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("tags.id"))
    tag = mainDB.relationship("Tag", backref=mainDB.backref('tagmap'))
    entry_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("entries.id"))

    def __init__(self, tag, entry):
        self.tag = tag
        self.entry_id = entry.id

    def __repr__(self):
        return "<Tag %s : Entry %s>" % (self.tag, self.entry_id)

# XXX CURRENTLY UNUSED
class DataType(mainDB.Model):
    __tablename__ = 'datatype'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    name = mainDB.Column(mainDB.String(20))

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return "<Type %s, id %s>" % (self.name, self.id)

class Entry(mainDB.Model):
    __tablename__ = 'entries'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    date = mainDB.Column(mainDB.DateTime())
    title = mainDB.Column(mainDB.String(256))
    entry = mainDB.Column(mainDB.String(40000))
    author_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("user.id"))
    author = mainDB.relationship("User")
    weight = mainDB.Column(mainDB.Integer)
    static = mainDB.Column(mainDB.Boolean)
    url = mainDB.Column(mainDB.String(32))
    tagmap = mainDB.relationship('TagMapping', backref=mainDB.backref('entries'))
    html = mainDB.Column(mainDB.Boolean)
    parent_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("entries.id"))
    children = mainDB.relationship('Entry', backref=mainDB.backref('parent',
        remote_side=[id]))

    def __init__(self, title, author, date, entry, weight=0, url=None, html=False, parent=None, static=False):
        self.date = date
        self.title = title
        self.author = author
        self.entry = entry
        self.weight = weight
        self.url = url
        self.html = html
        self.static = static
        if parent:
            self.parent_id = parent.id

    def __repr__(self):
        return "<Entry ID: %s, Title %s>" % (self.id, self.title)

class Activity(mainDB.Model):
    __tablename__ = 'activities'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    activity_type = mainDB.Column(mainDB.Integer)
    parameter = mainDB.Column(mainDB.String(256))
    name = mainDB.Column(mainDB.String(64))
    description = mainDB.Column(mainDB.String(256))
    date_added = mainDB.Column(mainDB.DateTime())

    def __init__(self, activity_type, parameter, date_added, name, description):
        self.activity_type = activity_type
        self.parameter = parameter
        self.date_added = date_added
        self.name = name
        self.description = description

    def __repr__(self):
        return "<Type '%s', Param '%s'>" % (self.activity_type, self.parameter)

class SiteConfig(mainDB.Model):
    __tablename__ = 'siteconfig'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    version = mainDB.Column(mainDB.Integer)
    site_name = mainDB.Column(mainDB.String(64))
    admin_email = mainDB.Column(mainDB.String(64))

    def __init__(self, version):
        self.version = version
        self.site_name = "Noink website"
        self.admin_email = None

    def __repr__(self):
        return "<Version '%s'>" % (self.version)

