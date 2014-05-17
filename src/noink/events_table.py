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
    'add_user' : "User '{0}' added",
    'add_group' : "Group '{0}' added",
    'add_entry' : "Entry '{0}' added",
    'del_entry' : "Entry '{0}' deleted",
    'update_entry' : "Entry '{0}' updated",
    'del_user' : "User '{0}' deleted",
    'add_tag' : "Tag '{0}' added",
    'update_siteconf' : "Site config updated to version '{0}'",
    'update_sitename' : "Site name updated to '{0}'",
    'add_role' : "Role '{0}' added",
    'rm_from_group' : "User '%s' remove from group '{0}'",
    'del_group' : "Group '{0}' deleted",
    'del_role' : "Role '{0}' deleted",
    'rebuild_static' : "Static site rebuilt scheduled"
}
