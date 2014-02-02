'''
Defines all the possible events that can be generated.

Note- you can very easily go "off the rails" and come up with your own events
to add to the event log, but I'd *strongly* recommend just sticking to these
here (or updating this list as needed) as we reserve the right to actually use
specific items here in future data parsing, searching, processing, etc.

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

event_table = {
    'db_setup' : 'Initial database creation',
    'db_finish' : 'Database initialization complete',
    'add_user' : "User '%s' added",
    'add_group' : "Group '%s' added",
    'add_entry' : "Entry '%s' added",
    'del_entry' : "Entry '%s' deleted",
    'del_user' : "User '%s' deleted",
    'add_tag' : "Tag '%s' added",
    'update_siteconf' : "Site config updated to version '%s'",
    'update_sitename' : "Site name updated to '%s'"
}
