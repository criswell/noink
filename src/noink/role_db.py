"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import datetime
from types import IntType

from noink import mainDB
from noink.data_models import Role, RoleMapping
from noink.user_db import UserDB
from noink.activity_table import get_activity_dict
from noink.exceptions import DuplicateRole, RoleNotFound
from noink.event_log import EventLog
from noink.pickler import pickle, depickle
from noink.util import string_types

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

    def get_role(self, role):
        """
        Given a role identifier, return the role object.

        @param role: The role. Can be role object, rid, or string name.
        """
        r = role
        if isinstance(role, IntType):
            r = self.find_role_by_id(role)
        elif isinstance(role, string_types):
            r = self.find_role_by_name(role)

        return r

    def get_rolemapping(self, user, group, role):
        """
        Given a user, group and role, will return the rolemap of the three,
        if it exists. Otherwise will return None.

        FIXME - Docstring
        """
        r = self.get_role(role)
        user_db = UserDB()
        u = user_db.get_user(user)
        g = user_db.get_group(group)

        return RoleMapping.query.filter_by(user=u).filter_by(
                group=g).filter_by(role=r).first()

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
            raise DuplicateRole("{0} already exists as a role with id "\
                    "'{1}'".format(name, str(exists)))

        if activities is None:
            activities = get_activity_dict(False)

        now = datetime.datetime.now()
        pact = pickle(activities)
        role = Role(name, description, pact, now)
        mainDB.session.add(role)
        mainDB.session.commit()
        blob = pickle({'id' : role.id})
        # XXX - Do we want to use the user ID of the person adding this role?
        self.eventLog.add('add_role', -1, True, blob, role.name)
        return role

    def update_role(self, role):
        """
        Given a role object, update the database with whatever changes it
        contains.
        """
        if isinstance(role, Role):
            exists = Role.query.get(role.id)
            if exists == []:
                mainDB.session.add(role)
            mainDB.session.commit()

    def create_temp_empty_role(self):
        """
        Returns a temporary, empty role object.
        """
        pact = pickle(get_activity_dict(False))
        return Role(None, None, pact, None)

    def update_temp_role_activities(self, role, acts):
        """
        Given a temportary role and updated activies for it, update it.

        Retuns updated role.
        """
        pact = pickle(acts)
        role.activities = pact
        return role

    def get_activities(self, role):
        '''
        Given a role, return the activities that role can do.

        @param role: The role to use. Can be a role object, a role.id, or a
                     role name.

        @return Decoded/decoupled activity dictionary
        '''
        r = self.get_role(role)

        if r is not None:
            return depickle(r.activities)
        else:
            return None

    def assign_role(self, user, group, role):
        '''
        Given a user, group and role, assign the user as the role when part of
        the group.

        @param user: The user. Can be user object, uid, or string name of the
                     user.
        @param group: The group. Can be group object, gid, or string name.
        @param role: The role. Can be role object, rid, or string name.
        '''
        userDB = UserDB()
        u = userDB.get_user(user)
        g = userDB.get_group(group)
        r = self.get_role(role)

        exist = RoleMapping.query.filter_by(user=u).filter_by(
                group=g).filter_by(role=r).all()

        if exist == []:
            rm = RoleMapping(r, u, g)
            mainDB.session.add(rm)

        mainDB.session.commit()

    def revoke_role(self, user, group, role):
        """
        Given a user, group and role, revoke the user's rights to that role
        when part of the group.

        @param user: The user. Can be a user object, uid, or string name of
                     the user.
        @param group: The group. Can be a group object, gid, or string name.
        @param role: The role. Can be role object, rid, or string name.
        """
        user_db = UserDB()
        u = user_db.get_user(user)
        g = user_db.get_group(group)
        r = self.get_role(role)
        rmaps = RoleMapping.query.filter_by(user=u).filter_by(
                group=g).filter_by(role=r).all()

        for rm in rmaps:
            mainDB.session.delete(rm)

        mainDB.session.commit()

    def delete_role(self, role):
        """
        Given a role, delete it from the database. Role can be integer,
        string or role object.
        """
        r = self.get_role(role)
        if role is not None:
            rid = int(r.id)
            rname = r.name
            mainDB.session.delete(r)
            mainDB.session.commit()
            self.eventLog.add('del_role', rid, True, None, rname)
        else:
            raise RoleNotFound('Role not found in database')

    def get_roles(self, user, group=None):
        '''
        Get the roles a given user has. Optionally, limit by group.

        @param user: The user. Can be user object, uid, or string name.
        @param group: Group to limit by. Can be group object, gid, or string
                      name.

        @return A list of role mappings.
        '''
        userDB = UserDB()
        u = userDB.get_user(user)
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
