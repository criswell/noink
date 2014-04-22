'''
Defines all the possible activity types.


##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

activities = [
    'new_post',
    'edit_post',
    'delete_post',
    'new_user',
    'edit_user',
    'edit_self',
    'edit_group',
    'view_users',
    'view_groups',
    'new_group'
]

def get_activity_dict(default=False):
    '''
    Returns a fresh dictionary for defining activities.

    All values will be set to false by default.

    @param default: The default value to set all activities to.
    '''
    return dict((i, default) for i in activities)
