#!/usr/bin/env python

'''
user_funcs tests
----------------
Tests pertaining to users and the Noink DB

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest

from testMain import testMain

from noink import mainApp
from noink.userDB import UserDB

class AddUser(unittest.TestCase):
    def setUp(self):
        self.testMain = testMain()

    def tearDown(self):
        del(self.testMain)

    def test_AddUser(self):
        #

if __name__ == '__main__':
    unittest.main()

