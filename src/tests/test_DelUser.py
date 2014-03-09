#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from .testRoot import RootClass

from noink.user_db import UserDB

class DelUser(RootClass):

    def test_DelUser(self):
        userDB = UserDB()
        uid = userDB.add("jontest", "pass", "Jon Q. Testuser").id

        userDB.delete(uid)
        testUser = userDB.find_user_by_id(uid)
        self.assertTrue(testUser == None)

if __name__ == '__main__':
    unittest.main()

