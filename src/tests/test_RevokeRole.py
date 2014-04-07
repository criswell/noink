#!/usr/bin/env python

'''
'''

import unittest

from testRoot import RootClass

from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.activity_table import get_activity_dict

class AssignRole(RootClass):

    def test_AssignRole(self):
        user_db = UserDB()
        role_db = RoleDB()
        u = user_db.add("jontest", "pass", "Jon Q. Testuser")
        g = user_db.add_group('test_group')
        user_db.add_to_group(u, g)
        r = role_db.add_role('test_role', 'test role', get_activity_dict(True))
        role_db.assign_role(u, g, r)
        all_roles_1st = set(rm.role for rm in role_db.get_roles(u))
        was_in_before = r in all_roles_1st
        role_db.revoke_role(u, g, r)
        all_roles_2nd = set(rm.role for rm in role_db.get_roles(u))
        not_in_after = r not in all_roles_2nd
        self.assertTrue(was_in_before and not_in_after)

if __name__ == '__main__':
    unittest.main()

