'''
Defines all the possible activity types.


##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

__activities = [
    'new_post',
    'edit_post',
    'top_level_post',
    'new_user',
    'edit_user',
    'edit_self'
]

activity_table = dict((v,k) for k,v in \
    enumerate(__activities, start=ord('a')))
