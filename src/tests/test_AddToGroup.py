#!/usr/bin/env python

'''
'''

import unittest

from testRoot import RootClass

from noink.user_db import UserDB

class AddToGroup(RootClass):

    def test_AddToGroup(self):
        user_db = UserDB()
        u = user_db.add("jontest", "pass", "Jon Q. Testuser")
        g = user_db.add_group('test_group')
        gid = g.id
        user_db.add_to_group(u, g)
        groups = set(user_db.get_users_groups(u))
        self.assertTrue(g in groups)

if __name__ == '__main__':
    unittest.main()

