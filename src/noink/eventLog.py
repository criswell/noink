'''
The main interface to the event log.

Everything should use this to interact with the event log, Nothing should work
with the log in the database directly but this.

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from noink import mainDB
from noink.dataModels import Event
from noink.eventsTable import eventTable

class EventLog:

    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

    def add(self, name, user, processed=False, *args):
        '''
        Adds an event to the log.

        @param name: The event name. Should correspond to entry in eventTable
        @param user: The id of the user generating the event
        @param processed: If the event should be marked as processed
        '''

        if eventTable.has_key(name):
            now = datetime.datetime.now()
            if len(args) > 0:
                e = Event(name, eventTable[name] % args, now, user)
            else:
                e = Event(name, eventTable[name], now, user)

            e.processed = processed
            if processed:
                e.processedDate = now

            mainDB.session.add(e)
            mainDB.session.commit()
        else:
            raise KeyError('%s not in eventTable!' % name)
