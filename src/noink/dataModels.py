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

    def __init__(self, name, fullname, bio):
        self.name = name
        self.fullname = fullname
        self.bio = bio

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
    processedDate = mainDB.Column(mainDB.DateTime())


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
    tag = mainDB.relationship("Tag")
    entry_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("entries.id"))
    entry = mainDB.relationship("Entry")

    def __init__(self, tag, entry):
        self.tag = tag
        self.entry = entry

    def __repr__(self):
        return "<Tag %s : Entry %s>" % (self.tag, self.entry)

class DataType(mainDB.Model):
    __tablename__ = 'datatype'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    name = mainDB.Column(mainDB.String(20))

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return "<Type %s, id %s>" % (self.name, self.id)

class URL(mainDB.Model):
    __tablename__ = 'urls'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    name = mainDB.Column(mainDB.String(32))
    emtry_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("entries.id"))
    entry = mainDB.relationship("Entry")

    def __init__(self, name, entry):
        self.name = name
        self.entry = entry

    def __repr__(self):
        return "<URL %s : Entry %s>" % (self.name, self.entry_id)

class Entry(mainDB.Model):
    __tablename__ = 'entries'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    date = mainDB.Column(mainDB.DateTime())
    title = mainDB.Column(mainDB.String(256))
    entry = mainDB.Column(mainDB.String(40000))
    author_id = mainDB.Column(mainDB.Integer, mainDB.ForeignKey("user.id"))
    author = mainDB.relationship("User")

    def __init__(self, title, author, date, entry):
        self.date = date
        self.title = title
        self.author = author
        self.entry = entry

    def __repr__(self):
        return "<Entry ID: %s, Title %s>" % (self.id, self.title)

class Activity(mainDB.Model):
    __tablename__ = 'activities'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    activityType = mainDB.Column(mainDB.Integer)
    parameter = mainDB.Column(mainDB.String(256))
    dateAdded = mainDB.Column(mainDB.DateTime())

    def __init__(self, activityType, parameter, dateAdded):
        self.activityType = activityType
        self.parameter = parameter
        self.dateAdded = dateAdded

    def __repre__(self):
        return "<Type '%s', Param '%s'>" % (self.activityType, self.parameter)

