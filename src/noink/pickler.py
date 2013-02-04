'''
Common pickle objects for Noink event logs

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from copy import copy, deepcopy
from pickle import dumps, loads

# Entries
class PEntry:
    def __init__(self, entry, url):
        self.id = copy(entry.id)
        self.title = copy(entry.title)
        if url:
            self.url = copy(url.name)

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
    return loads(string)
