#!/usr/bin/env python

'''
add user test

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from testRoot import RootClass

from noink.userDB import UserDB

class AddUser(RootClass):

    def test_AddUser(self):
        userDB = UserDB()
        u = userDB.add("jontest", "pass", "Jon Q. Testuser")
        uid = u.id
        self.assertTrue(uid > 0)

if __name__ == '__main__':
    unittest.main()

