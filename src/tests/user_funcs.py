#!/usr/bin/env python

'''
user_funcs tests
----------------
Tests pertaining to users and the Noink DB

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from noink import mainApp
from noink.userDB import UserDB

class StandardUserTestCase(unittest.TestCase):
    def setUp(self):
        self.userDB = UserDB()
        self.username = 'johndoughboy69'
        self.fullname = 'John Doughboy Esq.'
        self.invaliduser = 'johndoughboy70'
        self.validuser = 'killerpeadbody'
        self.validfull = 'Missy Pinky'
        self.user = self.userDB.add(self.validuser, self.validfull)

    def tearDown(self):
        self.userDB.delete(self.user)
        self.userDB.delete(self.userDB.findUserByName(self.username).first())
        self.userDB = None

    def test_AddUser(self):
        unittest.assertGreater(self.userDB.add(self.username, self.fullname), 0)

    def test_QueryUser(self):
        unittest.assertIsNotNone(self.userDB.findUserByName(self.username))

    def test_DelUser(self):
        self.userDB.delete(self.user)
        unittest.assertEqual(self.userDB.findUserByName(self.validuser).count(), 0)

if __name__ == '__main__':
    unittest.main()

