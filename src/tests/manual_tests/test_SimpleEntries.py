#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

from tests.testMain import testMain
from random import randint

from entries import entries

from noink import mainApp
from noink.user_db import UserDB
from noink.entry_db import EntryDB

class SimpleEntries:

    def __init__(self):
        self.testMain = testMain()

        self.userDB = UserDB()
        self.entryDB = EntryDB()

        u = self.userDB.add("criswell", "password", "Sam Hart")
        parents = []
        for e in entries:
            parent = None
            if randint(0,5) > 3 and len(parents) > 1:
                parent = parents[randint(0,len(parents)-1)]
            try:
                entry = self.entryDB.add(e[0], e[1], u, e[2], e[3], e[5], parent)
                if e[4]:
                    self.entryDB.add_tag(e[4], entry)

                if randint(0,5) > 2:
                    parents.append(entry)
            except:
                print "Dropping an entry due to some entryDB problem (likely duplicate URL"
                print "because of random URL generation- Should be safe to ignore)\n"
                pass # stupid, but for our tests we don't care we just may get duplicate URLs

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
        mainApp.run(host="0.0.0.0", debug=debug)

if __name__ == '__main__':
    se = SimpleEntries()
    se.run(True)
