"""
Our own freezing module. Inspired by, but different from, frozen flask.
"""

from noink.event_log import EventLog

class Icebox:

    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        try:
            self._setup
        except AttributeError:
            self._setup = False

        if not self._setup:
            self.event_log = EventLog()
            self._setup = True

    def generate_pages(self, all_pages=False):
        """
        Generate the pages.

        If all_pages is True, will regenerate the entire site.
        """
        pass

    def make_icebox_path(self, overwrite=True):
        """
        Make the icebox path.

        If overwrite is True, will overwrite whatever is there (default).
        """
        pass

    def clear_icebox_path(self):
        """
        Will clear the icebox path.

        WARNING: This is destructive, and should only be used when you know
        what you're doing. This will nuke the contents of the icebox path.
        """
        pass

    def _generate_page(self, entry):
        """
        Given an entry, will generate the page for it (including any
        aliases).
        """
        pass

    def _remove_page(self, entry):
        """
        Given an entry, will remove the page for it.
        """
        pass
