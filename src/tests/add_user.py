#!/usr/bin/env python

'''
add_user test
-------------
Adds a user to the Noink DB

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from noink import mainApp
from noink.userDB import UserDB

class AddUserCase(unittest.TestCase):
    def setUp(self):
        self.userDB = UserDB()

    def tearDown(self):
        self.userDB = None

    def test_AddUser(self):

