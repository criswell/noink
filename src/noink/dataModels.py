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

class
