"""

Custom tests for the templating engine

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from noink import mainApp
from noink.role_db import RoleDB

from flask.ext.login import current_user

def _role_test(entry, activity):
    '''
    Test to determine if an entry can have activity performed against it by
    the current_user

    @param entry: The entry to check against.
    @param activity: The activity to check.

    @return True if they can, false if not.
    '''
    if current_user.is_authenticated() and current_user.is_active():
        role_db = RoleDB()
        rm = role_db.get_roles(current_user)
        for m in rm:
            if m.group_id == entry.group_id:
                activities = role_db.get_activities(m.activities)
                return activities.get(activity, False)
    return False

@mainApp.template_test()
def is_editable(entry):
    '''
    Test to determine if an entry is editable by the current user.

    @param entry: The entry to check against.
    '''
    return _role_test(entry, 'edit_post')

@mainApp.template_test()
def is_deletable(entry):
    '''
    Test if entry is deletable by the current user.

    @param entry: The entry to check against.
    '''
    return _role_test(entry, 'delete_post')

