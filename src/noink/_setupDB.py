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
from noink.eventLog import EventLog
from noink.userDB import UserDB
from noink.siteConfig import _SiteConfig

def setupDB():
    eventLog = EventLog()
    sc = _SiteConfig()
    userDB = UserDB()
    mainDB.create_all()
    eventLog.add('db_setup', -1, True)
    user = userDB.add(mainApp.config['ADMIN_USER'], mainApp.config['ADMIN_FULLNAME'])
    userDB.addGroup(mainApp.config['ADMIN_GROUP'], user.id)

    sc.add(mainApp.noinkVersion, mainApp.config['SITE_NAME'], mainApp.config['SITE_ADMIN_EMAIL'])

    eventLog.add('db_finish', -1, True)

