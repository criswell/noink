#!/usr/bin/env python

'''
_setupDB.py
-----------
Initializes the database, setting any default values.

This should not be called externally, only by tools and applications that will
need it.

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

from noink import mainApp, mainDB
from noink.event_log import EventLog
from noink.user_db import UserDB
from noink.site_config import _SiteConfig
from noink.activity_table import get_activity_dict
from noink.role_db import RoleDB
from noink.exceptions import SetupError

def setup_DB():
    """
    Called when the DB is to be initialized. Should only be called once.
    """
    event_log = EventLog()
    sc = _SiteConfig()
    userDB = UserDB()
    roleDB = RoleDB()
    mainDB.create_all()
    event_log.add('db_setup', -1, True)
    default_group = userDB.add_group(mainApp.config['DEFAULT_GROUP'])
    default_acts = get_activity_dict(False)
    default_acts.update(mainApp.config['DEFAULT_ROLE_ACTIVITIES'])

    dummy = roleDB.add_role(
            mainApp.config['DEFAULT_ROLE_NAME'],
            mainApp.config['DEFAULT_ROLE_DESC'],
            default_acts)

    user = userDB.add(mainApp.config['ADMIN_USER'],
        mainApp.config["ADMIN_PASSWD"], mainApp.config['ADMIN_FULLNAME'])
    admin_group = userDB.add_group(mainApp.config['ADMIN_GROUP'], user.id)
    if not userDB.update_primary(user, admin_group):
        raise SetupError(
            'Could not assign the admin user "{0}" primary group to the ' \
            'admin group "{1}"!'.format(user, admin_group))

    # By default, the admin is part of the top level group as well as default
    dummy = userDB.add_group(mainApp.config['TOP_LEVEL_GROUP'],
        user.id)
    userDB.add_to_group(user, default_group)

    admin_role = get_activity_dict(True)
    role = roleDB.add_role(
            mainApp.config['ADMIN_ROLE_NAME'],
            mainApp.config['ADMIN_ROLE_DESC'],
            admin_role)

    roleDB.assign_role(user, mainApp.config['ADMIN_GROUP'], role)
    roleDB.assign_role(user, mainApp.config['TOP_LEVEL_GROUP'], role)
    roleDB.assign_role(user, mainApp.config['DEFAULT_GROUP'], role)

    sc.add(mainApp.noink_version, mainApp.config['SITE_NAME'],
            mainApp.config['SITE_ADMIN_EMAIL'])

    event_log.add('db_finish', -1, True)
