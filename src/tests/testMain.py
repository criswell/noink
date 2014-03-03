"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import os

import tempfile
import shutil
import random

from noink import mainApp
from noink import re_init
from noink import _setupDB

class testMain(object):
    def __init__(self, temp_path=None):
        if temp_path:
            self.TEST_ROOT = temp_path
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
            'DEFAULT_GROUP = "default"\n',
            'SQLALCHEMY_DATABASE_URI = "%s"\n' % self.TEST_DB_FILE,
            'SECRET_KEY = "%032x"\n' % random.getrandbits(128),
            'HTML_TEMPLATES = [ "../../noink/blueprints/templates/default" ]\n',
            'STATIC_PATH = "./blueprints/static/default"\n',
            'NUM_ENTRIES_PER_PAGE = [ 20, 50 ]\n',
            'BREAK_IDENTIFIER = "<!--break-->"\n',
            'LINEBREAK_TAG = "<br />"\n',
            'SITE_NAME = "Johnny\'s speedboat factory"\n',
            'SITE_ADMIN_EMAIL = "foo@bar.com"\n',
            'ADMIN_ROLE_NAME = "admin"\n',
            'ADMIN_ROLE_DESC = "Test admin role"\n',
            'TOP_LEVEL_GROUP = "top"\n'
        ]

        with open(self.TEST_CONF_FILE, 'w') as f:
            f.writelines(conf)
        re_init()

        _setupDB.setup_DB()

    def __del__(self):
            shutil.rmtree(self.TEST_ROOT, True)
