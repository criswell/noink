"""

Custom tests for the templating engine

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from noink import mainApp
from noink.role_db import RoleDB
from noink.user_db import UserDB

from flask.ext.login import current_user

def _role_test(entry, activity):
    """
    Test to determine if an entry can have activity performed against it by
    the current_user

    :param entry: The entry to check against.
    :param activity: The activity to check.

    :returns: True if they can, false if not.
    """
    if current_user.is_authenticated() and current_user.is_active():
        role_db = RoleDB()
        rm = role_db.get_roles(current_user)
        for m in rm:
            if m.group_id == entry.group_id:
                activities = role_db.get_activities(m.role)
                if activities.get(activity, False):
                    return True
    return False

def is_admin():
    """
    Test to determine if the user is an admin or not
    """
    is_a = False
    user_db = UserDB()
    if current_user.is_authenticated() and current_user.is_active():
        admin_group = user_db.get_group(mainApp.config['ADMIN_GROUP'])
        is_a = user_db.in_group(current_user, admin_group)
    return is_a

@mainApp.template_test('editable')
def is_editable(entry):
    """
    Test to determine if an entry is editable by the current user.

    :param entry: The entry to check against.
    """
    return _role_test(entry, 'edit_post')

@mainApp.template_test('deletable')
def is_deletable(entry):
    """
    Test if entry is deletable by the current user.

    :param entry: The entry to check against.
    """
    return _role_test(entry, 'delete_post')

@mainApp.template_test('possible_parent')
def is_possible_parent(entry):
    """
    Test if an entry is a possible parent for the current user.

    :param entry: The entry to check against.
    """
    can_edit = _role_test(entry, 'edit_post')
    can_make = _role_test(entry, 'new_post')
    return (can_edit & can_make)

