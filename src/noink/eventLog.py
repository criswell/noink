'''
The main interface to the event log.

Everything should use this to interact with the event log, Nothing should work
with the log in the database directly but this.

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

from noink import mainDB
from noink.dataModuls import Event
from noink.eventsTable import eventTable

class EventLog:

    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

    def add(self, name, user, processed=False):
        '''
        Adds an event to the log.

        @param name: The event name. Should correspond to entry in eventTable
        @param user: The id of the user generating the event
        @param processed: If the event should be marked as processed
        '''

        if eventTable.has_key(name):
            e = Event(name, eventTable[name],
