"""

Custom tests for the templating engine

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

#from noink.user_db import UserDB
from noink.role_db import RoleDB

from flask.ext.login import current_user

def is_editable(entry):
    '''
    Test to determine if an entry is editable by the current user.

    @param entry: The entry to check against.
    '''
    if current_user.is_authenticated() and current_user.is_active():
        role_db = RoleDB()
        rm = role_db.get_roles(current_user)
        for m in rm:
            if m.group_id == entry.group_id:
                activities = role_db.get_activities(m.activities)
                return activities.get('edit_post', False):
    return False

