#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

import unittest, copy

from testRoot import RootClass

from noink.user_db import UserDB
from noink.entry_db import EntryDB

class AddEntry(RootClass):

    def test_AddEntry(self):
        userDB = UserDB()
        entryDB = EntryDB()
        u = userDB.add("jontest", "pass", "Jon Q. Testuser")
        title = 'Little Buttercup'
        entry = 'There once was a man from Nantucket,' + \
                'who kept his wife in a Bucket.' + \
                "Wait... how'd she fit in that bucket anyway?"

        e = entryDB.add(copy.deepcopy(title), entry, u)
        self.assertTrue(e.title == title)

if __name__ == '__main__':
    unittest.main()

