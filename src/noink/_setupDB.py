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

def setupDB():
    eventLog = EventLog()
    userDB = UserDB()
    mainDB.create_all()
    eventLog.add('db_setup', -1, True)
    id = userDB.add(mainApp.config['ADMIN_USER'], mainApp.config['ADMIN_FULLNAME'])
    userDB.addGroup(mainApp.config['ADMIN_GROUP'], id)

    eventLog.add('db_finish', -1, True)

