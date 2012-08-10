"""
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
"""

from noink import mainDB

class User(mainDB.Model):
    __tablename__ = 'users'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    name = mainDB.Column(mainDB.String(60))
    fullname = mainDB.Column(mainDB.String(80))
    passwordHash = mainDB.Column(mainDB.String(256))
    bio = mainDB.Column(mainDB.String(4000))

    def __init__(self, name, fullname, passwordHash, bio):
        self.name = name
        self.fullname = fullname
        self.passwordHash = passwordHash
        self.bio = bio

    def __repr__(self):
        return "<User %s, id %s>" % (self.name, self.id)

class Event(mainDB.Model):
    __tablename__ = 'events'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    event = mainDB.Column(mainDB.String(40))
    description = mainDB.Column(mainDB.String(500))
    date = mainDB.Column(mainDB.DateTime())
    user = mainDB.Column(mainDB.Integer)

    def __init__(self, event, description, date, user):
        self.event = event
        self.description = description
        self.date = date
        self.user = user

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
    tag = mainDB.relationship("Tag")
    entry = mainDB.relationship("Entry")

    def __init__(self, tag, entry):
        self.tag = tag
        self.entry = entry

    def __repr__(self):
        return "<Tag %s : Entry %s>" % (self.tag, self.entry)

class Entry(mainDB.Model):
    __tablename__ = 'entries'

    id = mainDB.Column(mainDB.Integer, primary_key=True)
    date = mainDB.Column(mainDB.DateTime())
    title = mainDB.Column(mainDB.String(256))
    entry = mainDB.Column(mainDB.String(40000))
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

