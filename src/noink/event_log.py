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

        if name in event_table:
            now = datetime.datetime.now()
            if len(args) > 0:
                e = Event(name, event_table[name].format(*args), now, user,
                    blob)
            else:
                e = Event(name, event_table[name], now, user,
                    blob)

            e.processed = processed
            if processed:
                e.processed_date = now

            mainDB.session.add(e)
            mainDB.session.commit()
        else:
            raise KeyError('{0} not in event_table!'.format(name))

    def find_recent_by_num(self, num, offset=0):
        """
        Finds the recent events with a maximum of 'num'.
        """
        return Event.query.order_by(Event.date.desc()).offset(offset).limit(
            num).all()

    def count(self):
        """
        Returns the number of possible events
        """
        return Event.query.order_by(Event.date.desc()).count()

    def get_unprocessed(self):
        """
        Returns the unprocessed log entries
        """
        for i in range(self.count()):
            yield Event.query.order_by(Event.date).offset(i).first()

    def mark_as_processed(self, entry):
        """
        Marks an unprocessed entry as processed.
        """
        entry.processed = True
        now = datetime.datetime.now()
        entry.processed_date = now
        mainDB.session.commit()

