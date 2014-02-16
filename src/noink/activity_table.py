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

# FXIME- Fugly, probably too ineffecient even for something not designed
# for efficiency...
__tact = dict(enumerate(__activities, start=1))
activity_table = dict(zip(__tact.values(), __tact.keys()))
