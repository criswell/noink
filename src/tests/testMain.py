"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import os

import tempfile
import shutil
import random

from noink import mainApp
from noink import reInit
from noink import _setupDB

class testMain(object):
    def __init__(self, tempPath=None):
        if tempPath:
            self.TEST_ROOT = tempPath
        else:
            self.TEST_ROOT = tempfile.mkdtemp()

        # Need a temporary files and settings
        self.TEST_CONF_FILE = "%s/test.cfg" % self.TEST_ROOT
        os.environ['NOINK_CONFIGURATION'] = self.TEST_CONF_FILE

        self.TEST_DB_FILE = "sqlite:///%s/noink.db" % self.TEST_ROOT

        conf = [
            'ADMIN_USER = "admin"\n',
            'ADMIN_PASSWD = "password"\n',
            'ADMIN_FULLNAME = "Administrator"\n',
            'ADMIN_GROUP = "admin"\n',
            'SQLALCHEMY_DATABASE_URI = "%s"\n' % self.TEST_DB_FILE,
            'SECRET_KEY = "%032x"\n' % random.getrandbits(128),
            'HTML_TEMPLATES = [ "../../noink/blueprints/templates/default" ]\n',
            'STATIC_PATH = "./blueprints/static/default"\n',
            'NUM_ENTRIES_PER_PAGE = [ 20, 50 ]\n',
            'BREAK_IDENTIFIER = "<!--break-->"\n',
            'LINEBREAK_TAG = "<br />"\n',
            'SITE_NAME = "Johnny\'s speedboat factory"\n',
            'SITE_ADMIN_EMAIL = "foo@bar.com"\n'
        ]

        with open(self.TEST_CONF_FILE, 'w') as f:
            f.writelines(conf)
        reInit()

        _setupDB.setupDB()

    def __del__(self):
            shutil.rmtree(self.TEST_ROOT, True)
