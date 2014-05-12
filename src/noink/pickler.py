'''
Common pickle objects for Noink event logs

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from copy import copy
from pickle import dumps, loads

from noink.util import string_types as _string_types

# Entries
class PEntry:
    def __init__(self, entry):
        self.id = copy(entry.id)
        self.title = copy(entry.title)
        self.url = copy(entry.url)

def pickle(obj):
    '''
    Takes an object to be pickled, will return the pickled string.

    @param obj: Object to be pickled.

    @return String of pickled object.
    '''
    return dumps(obj)

def depickle(string):
    '''
    Takes a pickled string, and returns the de-pickled object.

    @param string: Pickled string.

    @return De-pickled object.
    '''
    if isinstance(string, _string_types):
        return loads(string)
    else:
        return loads(str(string))

