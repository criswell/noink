#!/usr/bin/env python

'''
'''

import unittest

from testRoot import RootClass

from noink.user_db import UserDB
from noink import mainCrypt

class UpdatePassword(RootClass):

    def test_UpdatePassword(self):
        user_db = UserDB()
        u = user_db.add("jontest", "pass", "Jon Q. Testuser")
        passwd = 'A Test Password'
        self.assertFalse(mainCrypt.check_password_hash(u.passhash, passwd))
        user_db.update_password(u, passwd)
        self.assertTrue(mainCrypt.check_password_hash(u.passhash, passwd))

if __name__ == '__main__':
    unittest.main()

