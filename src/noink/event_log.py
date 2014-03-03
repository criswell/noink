'''
The main interface to the event log.

Everything should use this to interact with the event log, Nothing should work
with the log in the database directly but this.

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

import datetime

from noink import mainDB
from noink.data_models import Event
from noink.events_table import event_table

class EventLog:

    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

    def add(self, name, user, processed=False, blob='', *args):
        '''
        Adds an event to the log.

        @param name: The event name. Should correspond to entry in event_table
        @param user: The id of the user generating the event
        @param processed: If the event should be marked as processed
        '''

        if event_table.has_key(name):
            now = datetime.datetime.now()
            if len(args) > 0:
                e = Event(name, event_table[name] % args, now, user, blob)
            else:
                e = Event(name, event_table[name], now, user, blob)

            e.processed = processed
            if processed:
                e.processed_date = now

            mainDB.session.add(e)
            mainDB.session.commit()
        else:
            raise KeyError('%s not in event_table!' % name)

    def get_next_unprocessed(self):
        """
        Returns the next unprocessed log entry
        """
        pass

    def mark_as_processed(self, entry):
        """
        Marks an unprocessed entry as processed.
        """
        pass
