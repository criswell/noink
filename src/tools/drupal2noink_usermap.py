#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Tool for generating a mapping file between drupal and noink.

import sqlite3
import sys

from noink.user_db import UserDB

if len(sys.argv) != 3:
    print("usage:")
    print("{0} /path/to/sqlite.db outfile".format(sys.argv[0]))
    sys.exit(1)

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

userdb = UserDB()
users = userdb.get_all_users()

def display_users():
    print("ID\t:User")
    print("--\t:----")
    for u in users:
        print("{0}\t:{0}".format(u.id, u.name))

with open(sys.argv[2], 'w') as outfile:
    for row in c.execute("select * from users"):
        display_users()
        print("\nUser ID: {0}".format(row[0]))
        print("Username: {0}".format(row[1]))
        uid = input("Enter a user mapping or -1 for no map: ")
        print("--------------------")
        if uid >= 0:
            outfile.write("{0},{0}\n".format(uid, row[0]))

