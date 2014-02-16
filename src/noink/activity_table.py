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

# FIXME - Should this be enumerated to ensure that the
# numbers match across upgrades?
activity_table = dict(zip(
    __activities, range(1, len(__activities) + 1)))
