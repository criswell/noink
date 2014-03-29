"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import datetime
from types import IntType, StringType

from noink import mainDB
from noink.data_models import Role, RoleMapping
from noink.user_db import UserDB
from noink.activity_table import activities as all_activities
from noink.activity_table import get_activity_dict
from noink.exceptions import DuplicateRole
from noink.event_log import EventLog
from noink.pickler import pickle, depickle
from noink.exceptions import NoRolesFound

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
        self.eventLog.add('add_role', -1, True, blob)
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

        return depickle(r.activities)

    def assign_role(self, user, group, role):
        '''
        Given a user, group and role, assign the user as the role when part of
        the group.

        @param user: The user. Can be user object, uid, or string name of the
                     user.
        @param group: The group. Can be group object, gid, or string name.
        @param role: The role. Can be role object, rid, or stringe name.
        '''
        userDB = UserDB()
        u = userDB.get_user(user)[0]
        g = userDB.get_group(group)
        r = role
        if type(role) is IntType:
            r = self.find_role_by_id(role)
        elif type(role) is StringType:
            r = self.find_role_by_name(role)

        exist = RoleMapping.query.filter_by(user=u).filter_by(group=g).filter_by(role=r).all()

        if exist == []:
            rm = RoleMapping(r, u, g)
            mainDB.session.add(rm)

        mainDB.session.commit()

    def get_roles(self, user, group=None):
        '''
        Get the roles a given user has. Optionally, limit by group.

        @param user: The user. Can be user object, uid, or string name.
        @param group: Group to limit by. Can be group object, gid, or string
                      name.

        @return A list of role mappings.
        '''
        userDB = UserDB()
        u = userDB.get_user(user)[0]
        rm = RoleMapping.query.filter_by(user=u)
        if group is not None:
            g = userDB.get_group(group)
            rm = rm.filter_by(group=g)

        return rm.all()

    def get_all_roles(self):
        '''
        Get all the available roles
        '''
        return Role.query.all()
