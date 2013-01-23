"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

import os

import tempfile
import shutil

#from noink import _setupDB

class testMain(object):
    def __init__(self):
        self.TEST_ROOT = tempfile.mkdtemp()

        # Need a temporary files and settings
        self.TEST_CONF_FILE = "%s/test.cfg" % self.TEST_ROOT
        #os.environ['NOINK_CONFIGURATION'] = self.TEST_CONF_FILE

        self.TEST_DB_FILE = "sqlite:///%s/noink.db" % self.TEST_ROOT

        TEST_ADMINUSER = "admin"
        TEST_ADMINFULL = "Administrator"
        TEST_ADMINGROUP = "admin"

        #confFile = open(self.TEST_CONF_FILE, 'w')
        #confFile.writelines(['SQLALCHEMY_DATABASE_URI = "%s"' % self.TEST_DB_FILE])
        #confFile.close()

        # Set ourselves up a test root for things
        from noink import _setupDB
        from noink import mainApp
        mainApp.config['SQLALCHEMY_DATABASE_URI'] = self.TEST_DB_FILE
        _setupDB.setupDB()

    def __del__(self):
            shutil.rmtree(self.TEST_ROOT, True)
