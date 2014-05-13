#!/usr/bin/env python

'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

from argparse import ArgumentParser

from tests.testMain import testMain
from random import randint, sample

from entries import entries

from noink import mainApp
from noink.user_db import UserDB
from noink.entry_db import EntryDB
from noink.role_db import RoleDB
from noink.icebox import Icebox

class SimpleEntries:

    def __init__(self):
        self.testMain = testMain()

        self.userDB = UserDB()
        self.entryDB = EntryDB()
        self.roleDB = RoleDB()

        u = self.userDB.add("criswell", "password", "Sam Hart")
        u1 = self.userDB.add("charles", "password", "Charles Xavier")
        u2 = self.userDB.add("leif", "password", "Lief Ericsson")
        u3 = self.userDB.add("barf", "password", "Barfy Barferson")
        u4 = self.userDB.add("squiddy", "password", "Squidward Tentacles")
        editors = ['charles', 'leif', 'barf', 'squiddy']
        all_groups = ['junkbar', 'dollarbillyall', 'coldnwet']
        for g in all_groups:
            self.userDB.add_group(g)
        role_names = ['tomato', 'spaghetti', 'nuts']
        role_desc = ['Tomato Paste', 'Swirly Cheesy', 'Hardcore Nuts']
        for x in range(len(role_names)):
            self.roleDB.add_role(
                role_names[x],
                role_desc[x])
        parents = []
        for e in entries:
            parent = None
            if randint(0,5) > 3 and len(parents) > 1:
                parent = parents[randint(0,len(parents)-1)]
            try:
                entry = self.entryDB.add(e[0], e[1], u, None, e[2], e[3], e[5], parent)
                if e[4]:
                    self.entryDB.add_tag(e[4], entry)

                if randint(0,5) > 2:
                    parents.append(entry)

                if randint(0,5) > 2:
                    for ed in sample(editors, randint(1,len(editors)-1)):
                        self.entryDB.update_editor(ed, entry)
            except:
                print("Dropping an entry due to some entryDB problem (likely duplicate URL")
                print("because of random URL generation- Should be safe to ignore)\n")
                pass # stupid, but for our tests we don't care we just may get duplicate URLs

    def __del__(self):
        del(self.testMain)

    def run(self, debug):
        print("mainApp.jinja_env")
        print("-----------------")
        print(dir(mainApp.jinja_env))
        print("\nmainApp.jinja_loader")
        print("___________________")
        print(dir(mainApp.jinja_loader))
        print("\n%s" % mainApp.jinja_loader.searchpath)
        mainApp.run(host="0.0.0.0", debug=debug)

if __name__ == '__main__':
    parser = ArgumentParser(description='Simple, manual noink test')
    parser.add_argument('-f', help='Freeze the site and output static',
            action='store_true')
    args = parser.parse_args()
    se = SimpleEntries()
    if args.f:
        icebox = Icebox()
        icebox.generate_pages()
    else:
        se.run(True)
