#!/usr/bin/env python

'''
'''

import unittest

from testRoot import RootClass

from noink.role_db import RoleDB
from noink.activity_table import get_activity_dict

class AddRole(RootClass):

    def test_AddRole(self):
        role_db = RoleDB()
        r1 = role_db.add_role('test_role', 'A test role', get_activity_dict(True))
        r2 = role_db.get_role('test_role')
        self.assertEqual(r1.id, r2.id)

if __name__ == '__main__':
    unittest.main()

