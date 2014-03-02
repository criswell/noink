"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import datetime
from types import IntType, StringType

from noink import mainDB
from noink.data_models import Role, RoleMapping
from noink.activity_table import activities as all_activities
from noink.activity_table import get_activity_dict
from noink.exceptions import DuplicateRole
from noink.event_log import EventLog
from noink.pickler import pickle, depickle

class RoleDB:
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

    def find_role_by_name(self, rolename):
        '''
        Finds a role by it's name.

        @param rolename: The name of the role.

        @return The role object found.
        '''
        return Role.query.filter_by(name=rolename).first()

    def find_role_by_id(self, rid):
        '''
        Find a role by its role ID.

        @param rid: The role ID to find.

        @return The role object found.
        '''
        return Role.query.get(rid)

    def add_role(self, name, description, activities=None):
        '''
        Add a new role to the DB.

        @param name: Short, descriptive name of the role. Must be unique.
        @param description: Longer description of the role.
        @param activities: An activity dict defining the role's activities.
                           If parameter is omitted, then a default dict is used.
        '''
        try:
            exists = self.find_role_by_name(name)
        except:
            exists = False

        if exists:
            raise DuplicateRole("%s already exists as a role with id '%s'" % (name, str(exists)))

        if activities is None:
            activities = get_activity_dict(False)

        now = datetime.datetime.now()
        pact = pickle(activities)
        role = Role(name, description, pact, now)
        mainDB.session.add(role)
        mainDB.session.commit()
        blob = pickle({'id' : role.id})
        # XXX - Do we want to use the user ID of the person adding this role?
        self.eventLog.add('add_role', None, True, blob)
        return role

    def get_activities(self, role):
        '''
        Given a role, return the activities that role can do.

        @param role: The role to use. Can be a role object, a role.id, or a
                     role name.

        @return Decoded/decoupled activity dictionary
        '''

        r = role
        if type(role) is IntType:
            r = self.find_role_by_id(role)
        elif type(role) is StringType:
            r = self.find_role_by_name(role)

        return depickle(role.activities)

