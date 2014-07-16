#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Tool for importing existing drupal entries into noink.

import sqlite3
import sys
import datetime

from noink import mainApp
from noink.user_db import UserDB
from noink.entry_db import EntryDB

if len(sys.argv) != 3:
    print("usage:")
    print("{0} /path/to/sqlite.db mapfile".format(sys.argv[0]))
    sys.exit(1)

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

usermap = {}

with open(sys.argv[2], 'r') as mapfile:
    for i in mapfile.readlines():
        k = i.split(',')
        if len(k) == 2:
            usermap[k[1].strip()] = int(k[0])

user_db = UserDB()
entry_db = EntryDB()

all_admin = user_db.find_user_by_name(mainApp.config['ADMIN_USER'])
if len(all_admin) == 1:
    admin = all_admin[0]
else:
    print("Can't find admin: {0}".format(mainApp.config['ADMIN_USER']))
    sys.exit(1)

all_urls = {}
for r in c.execute("select * from url_alias"):
    nid = int(r[1].split('/')[1])
    all_urls[nid] = r[2]

class Entry(object):
    def __init__(self, row, user, node, terms, url):
        self.nid = row[0]
        self.vid = row[1]
        self.type = row[2]
        self.title = row[3]
        self.user = str(user[0][0])
        self.created = row[6]
        self.updated = row[7]
        self.body = node[4]
        self.teaser = node[5]
        self.format = node[8]
        self.terms = terms
        self.url = url
        self.parent = None
        self.weight = 0

def gen_entry(row):
    #c = conn.cursor()
    c2 = conn.cursor()
    user = c.execute("select name from users where uid = {0}".format(
        row[4])).fetchall()
    node = c.execute("select * from node_revisions where vid = {0}".format(
        row[1])).fetchall()[0]
    terms = []
    for elem in c2.execute("select * from term_node where nid={0}".format(
        row[0])):
        t = c.execute("select name from term_data where tid={0}".format(
            elem[1])).fetchone()[0]
        terms.append(t)
    url = None
    if row[0] in all_urls:
        url = all_urls[row[0]]
    en = Entry(row, user, node, terms, url)

    parent_info = c.execute(
            "select parent,weight from book where nid={0}".format(
                row[0])).fetchall()
    if len(parent_info) == 1:
        en.parent = parent_info[0][0]
        en.weight = parent_info[0][1]

    return en

def get_nodes():
    lc = conn.cursor()
    for row in lc.execute("select * from node order by nid"):
        try:
            yield gen_entry(row)
        except:
            print("!!Problem with entry number {0}".format(row[1]))

def add_blank_entry():
    return entry_db.add("Delme", "Delme", admin)

parent_list = {}
eid = 0
entries_to_delete = []

for e in get_nodes():
    u = user_db.find_user_by_id(usermap[e.user])
    if u is None:
        u = admin

    eid = eid + 1
    print("{0}:{1}".format(eid, e.title.encode('utf-8')))

    while eid < e.nid:
        entries_to_delete.append(add_blank_entry())
        eid = eid + 1

    ae = entry_db.add(e.title, e.body, u, None, e.weight,
            e.url, True, None, datetime.datetime.fromtimestamp(e.created))

    if e.parent is not None:
        parent_list[ae.id] = e.parent

# Delete missing nodes
for e in entries_to_delete:
    entry_db.delete(e)

for i in parent_list:
    e = entry_db.find_by_id(int(i))
    e.parent_id = int(parent_list[i])
    entry_db.update_entry(e)
