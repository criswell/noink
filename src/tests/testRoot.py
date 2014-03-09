'''
test_Root.py
----------------
The root class for all other classes.

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest
from .testMain import testMain

class RootClass(unittest.TestCase):
    def setUp(self):
        self.testMain = testMain()

    def tearDown(self):
        del(self.testMain)

