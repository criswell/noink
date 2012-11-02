#!/usr/bin/env python

'''
setup_db.py
-----------
Initializes the database, setting any default values
'''

from noink import mainDB
mainDB.create_all()

