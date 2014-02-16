'''
Defines all the possible activity types.


##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

# NOTE: The following list should not change order!
# New items should always be added at end, and existing
# items should not be re-ordered!
__activities = [
    'new_post',
    'edit_post',
    'delete_post',
    'new_user',
    'edit_user',
    'edit_self',
    'group_admin'
]

activity_table = dict((v,k) for k,v in \
    enumerate(__activities, start=ord('a')))
