#!/usr/bin/env python

'''
'''

import unittest

from testRoot import RootClass

from noink.user_db import UserDB

class AddGroup(RootClass):

    def test_AddGroup(self):
        user_db = UserDB()
        g = user_db.add_group('test_group')
        self.assertTrue(g.id > 0)

if __name__ == '__main__':
    unittest.main()

