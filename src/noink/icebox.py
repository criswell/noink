"""
Our own freezing module. Inspired by, but different from, frozen flask.
"""

from os.path import abspath, isdir, dirname, join, relpath, isfile
from os import makedirs, remove, link, walk
from math import ceil
from glob import glob

from noink import mainApp
from noink.event_log import EventLog
from noink.pickler import depickle
from noink.entry_db import EntryDB
from noink.state import State

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
            if mainApp.config['ICEBOX_STATIC_PATH'] is not None:
                self.static_path = abspath(mainApp.config['ICEBOX_STATIC_PATH'])
            else:
                self.static_path = None
            self.client = mainApp.test_client()
            self._setup = True

    def generate_pages(self, all_pages=False):
        """
        Generate the pages.

        If all_pages is True, will regenerate the entire site.
        """
        if not isdir(self.icebox_path):
            makedirs(self.icebox_path)

        state = State()
        state.icebox = True

        if all_pages:
            pass
        else:
            for e in self.event_log.get_unprocessed():
                if e.event in ('add_entry', 'update_entry'):
                    pe = depickle(e.blob)
                    entry = self.entry_db.find_by_id(pe.id)
                    if entry is not None:
                        self._generate_page(entry)
                elif e.event == 'del_entry':
                    pe = depickle(e.blob)
                    self._remove_page(pe.id, pe.url)

        # Regenerate index
        self._generate_index()

        # Regenerate tags

        # Sync static pages
        if self.static_path:
            self.sync_static()

    def sync_static(self):
        """
        Synchronize static content
        """
        base_dir = "{0}/s".format(self.icebox_path)
        if not isdir(base_dir):
            makedirs(base_dir)
        for root, dirs, files in walk(join(self.icebox_path, 's')):
            for f in files:
                if isfile(join(root, f)):
                    remove(join(root, f))

        for root, dummy, files in walk(self.static_path):
            for f in files:
                source_name = join(root, f)
                dest_name = join(join(
                    '{0}/s'.format(self.icebox_path),
                    relpath(root, self.static_path)), f)
                base_dest = dirname(dest_name)
                if not isdir(base_dest):
                    makedirs(base_dest)
                link(source_name, dest_name)

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

        if entry.url:
            filename = self._convert_url_to_path(entry.url)
            self._write_page(html, filename)

    def _generate_index(self):
        """
        Generate the main index
        """
        # First clear the old indexes out of the way
        rmfiles = ['{0}/index.html'.format(self.icebox_path)]
        rmfiles.extend(glob('{0}/index_page_*'.format(self.icebox_path)))
        for f in rmfiles:
            if isfile(f):
                remove(f)

        per_page = mainApp.config['NUM_ENTRIES_PER_PAGE'][0]
        count = self.entry_db.count()
        total_pages = 0
        if count > per_page:
            total_pages = int(ceil(float(count) / float(per_page)))

        response = self.client.get('/', follow_redirects=True)
        html = response.data
        filename = 'index.html'
        self._write_page(html, filename)

        for i in range(total_pages):
            response = self.client.get('/?page={0}'.format(i),
                follow_redirects=True)
            html = response.data
            filename = 'index_page_{0}.html'.format(i)
            self._write_page(html, filename)

    def _write_page(self, html, filename):
        """
        Write the actual page to filename
        """
        fullname = "{0}/{1}".format(self.icebox_path, filename)
        base_dir = dirname(fullname)
        if not isdir(base_dir):
            makedirs(base_dir)

        with open(fullname, 'wb') as fd:
            fd.write(html)

    def _remove_page(self, entry_id, entry_url):
        """
        Given an entry, will remove the page for it.
        """
        pass
