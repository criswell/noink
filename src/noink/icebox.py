"""
Our own freezing module. Inspired by, but different from, frozen flask.
"""

from os.path import abspath, isdir, dirname
from os import makedirs

from noink import mainApp
from noink.event_log import EventLog
from noink.pickler import depickle
from noink.entry_db import EntryDB

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
            self.entry_db = EntryDB()
            self.icebox_path = abspath(mainApp.config['ICEBOX_PATH'])
            self.client = mainApp.test_client()
            self._setup = True

    def generate_pages(self, all_pages=False):
        """
        Generate the pages.

        If all_pages is True, will regenerate the entire site.
        """
        if not isdir(self.icebox_path):
            makedirs(self.icebox_path)

        if all_pages:
            pass
        else:
            for e in self.event_log.get_unprocessed():
                if e.event in ('add_entry', 'update_entry'):
                    pe = depickle(e.blob)
                    #import ipdb; ipdb.set_trace()
                    entry = self.entry_db.find_by_id(pe.id)
                    if entry is not None:
                        self._generate_page(entry)
                elif e.event == 'del_entry':
                    pe = depickle(e.blob)
                    self._remove_page(pe.id, pe.url)

        # Regenerate tags

        # Sync static pages

    def clear_icebox_path(self):
        """
        Will clear the icebox path.

        WARNING: This is destructive, and should only be used when you know
        what you're doing. This will nuke the contents of the icebox path.
        """
        pass

    def _convert_url_to_path(self, url):
        """
        Given a URL, convert it to a filepath.

        Return filepath.
        """
        if url.endswith('/'):
            url += 'index.html'
        else:
            url += '.html'

        if url.startswith('/'):
            return url[1:]
        else:
            return url

    def _generate_page(self, entry):
        """
        Given an entry, will generate the page for it (including any
        aliases).
        """
        response = self.client.get('/node/{0}'.format(entry.id),
            follow_redirects=True)
        html = response.data
        # First, generate the node
        filename = 'node/{0}.html'.format(entry.id)
        self._write_page(html, filename)

        filename = self._convert_url_to_path(entry.url)
        self._write_page(html, filename)

    def _write_page(self, html, filename):
        """
        Write the actual page to filename
        """
        base_dir = dirname(filename)
        if not isdir(base_dir):
            makedirs(base_dir)

        with open(filename, 'wb') as fd:
            fd.write(html)

    def _remove_page(self, entry_id, entry_url):
        """
        Given an entry, will remove the page for it.
        """
        pass
