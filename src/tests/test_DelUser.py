#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from test_Root import RootClass

from noink.userDB import UserDB

class DelUser(RootClass):

    def test_DelUser(self):
        userDB = UserDB()
        uid = userDB.add("jontest", "Jon Q. Testuser")

        userDB.delete(uid)
        testUser = userDB.findUserById(uid)
        self.assertTrue(testUser == None)

if __name__ == '__main__':
    unittest.main()

