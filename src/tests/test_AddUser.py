#!/usr/bin/env python

'''
user_funcs tests
----------------
Tests pertaining to users and the Noink DB

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from test_Root import RootClass

#from noink import mainApp
from noink.userDB import UserDB

class AddUser(RootClass):

    def test_AddUser(self):
        userDB = UserDB()
        uid = userDB.add("jontest", "Jon Q. Testuser")
        self.assertTrue(uid > 0)

if __name__ == '__main__':
    unittest.main()

