#!/usr/bin/env python

'''
'''

import unittest

from testRoot import RootClass

from noink.user_db import UserDB

class UpdatePrimary(RootClass):

    def test_UpdatePrimary(self):
        user_db = UserDB()
        u = user_db.add("jontest", "pass", "Jon Q. Testuser")
        g = user_db.add_group('test_group')
        self.assertTrue(user_db.update_primary(u, g))

if __name__ == '__main__':
    unittest.main()

