#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from testRoot import RootClass

from noink.user_db import UserDB

class RmFromGroup(RootClass):

    def test_RmFromGroup(self):
        userDB = UserDB()
        u = userDB.add("jontest", "pass", "Jon Q. Testuser")
        g_foo = userDB.add_group('foo')
        g_bar = userDB.add_group('bar')

        self.assertTrue(userDB.update_primary(u, g_foo))
        userDB.add_to_group(u, g_bar)

        self.assertTrue(userDB.in_group(u, g_bar))

        self.assertTrue(userDB.remove_from_group(u, g_bar))

        self.assertFalse(userDB.in_group(u, g_bar))

if __name__ == '__main__':
    unittest.main()

