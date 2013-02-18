#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

from tests.testMain import testMain

from entries import entries

from noink import mainApp
from noink.userDB import UserDB
from noink.entryDB import EntryDB

class SimpleEntries:

    def __init__(self):
        self.testMain = testMain()

        self.userDB = UserDB()
        self.entryDB = EntryDB()

        u = self.userDB.add("criswell", "Sam Hart")
        for e in entries:
            entry = self.entryDB.add(e[0], e[1], u, e[2], e[3], e[5])
            if e[4]:
                self.entryDB.addTag(e[4], entry)
            print entry.tagmap

    def __del__(self):
        del(self.testMain)

    def run(self, debug):
        print "mainApp.jinja_env"
        print "-----------------"
        print dir(mainApp.jinja_env)
        print "\nmainApp.jinja_loader"
        print "___________________"
        print dir(mainApp.jinja_loader)
        print "\n%s" % mainApp.jinja_loader.searchpath
        mainApp.run(debug=debug)

if __name__ == '__main__':
    se = SimpleEntries()
    se.run(True)
