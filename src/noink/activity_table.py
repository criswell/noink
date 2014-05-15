'''
Defines all the possible activity types.


##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

activities = {
        'new_post' : "Can make a new post",
        'edit_post' : "Can edit a post",
        'delete_post' : "Can delete a post",
        'new_user' : "Can create a new user",
        'edit_user' : "Can edit a user",
        'edit_self' : "Can edit their user",
        'edit_group' : "Can edit groups",
        'view_users' : "Can view users",
        'view_groups' : "Can view groups",
        'new_group' : "Can create groups",
        'view_roles' : "Can view roles",
        'edit_role' : "Can edit roles",
        'new_role' : "Can create new roles",
        'view_log' : "Can view the event log",
        'make_static' : "Can generate the static site"
        }

def get_activity_dict(default=False):
    '''
    Returns a fresh dictionary for defining activities.

    All values will be set to false by default.

    @param default: The default value to set all activities to.
    '''
    return dict((i, default) for i in activities)
