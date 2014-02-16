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

def setup_DB():
    event_log = EventLog()
    sc = _SiteConfig()
    userDB = UserDB()
    mainDB.create_all()
    event_log.add('db_setup', -1, True)
    userDB.add_group(mainApp.config['DEFAULT_GROUP'])
    user = userDB.add(mainApp.config['ADMIN_USER'], mainApp.config["ADMIN_PASSWD"], mainApp.config['ADMIN_FULLNAME'])
    userDB.add_group(mainApp.config['ADMIN_GROUP'], user.id)

    sc.add(mainApp.noink_version, mainApp.config['SITE_NAME'], mainApp.config['SITE_ADMIN_EMAIL'])

    event_log.add('db_finish', -1, True)

