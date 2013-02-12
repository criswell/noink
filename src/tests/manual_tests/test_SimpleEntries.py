#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

from tests.testMain import testMain

entries = \
[
    (
        'The Amazing Bambini',
        "So, my daughter is pretty amazing. She's got all sorts of mad skillz.\n\n" + \
        "She says 'eww yucky' when I fart. She can climb just about anything. She can " + \
        "run really fast and hide really well (usually when I am trying to change her " + \
        "diaper.)\n\n" + \
        "<!--break-->\n\n" + \
        "She loves Yo Gabba Gabba, for some silly reason- likely all that communism... " + \
        "babies <i>love</i> communism, just ask Billy O'!"
    ),
    (
        'Rabbit Rabbit Rabbit',
        "Rabbit rabbit rabbit, rabbit rabbit rabbit rabbit? Rabbit, rabbit rabbit. " + \
        "Rabbit! Rabbit, rabbit, rabbit!\n\n" + \
        "Rabbit rabbit rabbit rabbit..... rabbit... rabbit rabbit, rabbit? Rabbit- rabbit " + \
        "rabbit rabbit. Rabbit rabbit rabbit rabbit rabbit rabbit rabbit. Rabbit rabbit " + \
        "rabbit rabbit. <!--break--> Rabbit, rabbit? Rabbit, rabbit!\n\n" + \
        "Rabbit rabbit rabbit rabbit rabbit rabbit cheesecake artichoke!"
    )
]

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
            entry = self.entryDB.add(e[0], e[1], u)

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
