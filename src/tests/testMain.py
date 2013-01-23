"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import os

import tempfile
import shutil

from noink import _setupDB

class testMain:
    def __init__(self):
        self.TEST_ROOT = tempfile.mkdtemp()

        # Need a temporary files and settings
        self.TEST_CONF_FILE = "%s/test.cfg" % TEST_ROOT
        os.environ['NOINK_CONFIGURATION'] = TEST_CONF_FILE

        self.TEST_DB_FILE = "sqlite:///%s/noink.db" % TEST_ROOT

        TEST_ADMINUSER = "admin"
        TEST_ADMINFULL = "Administrator"
        TEST_ADMINGROUP = "admin"

        confFile = open(self.TEST_CONF_FILE, 'w')
        print('SQLALCHEMY_DATABASE_URI = "%s"' % self.TEST_DB_FILE, file=confFile)
        confFile.close()

        # Set ourselves up a test root for things
        _setupDB.setupDB()

    def __del__(self):
            shutil.rmtree(self.TEST_ROOT, True)
