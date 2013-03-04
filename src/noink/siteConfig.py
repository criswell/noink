"""
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
"""

from noink import mainDB
from noink.dataModels import SiteConfig
from noink.eventLog import EventLog

class _SiteConfig:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        try:
            self._setup
        except AttributeError:
            self._setup = False

        if not self._setup:
            self.eventLog = EventLog()
            self._setup = True

    def add(self, version, name=None, email=None):
        """
        Adds an entry to the site config database.
        """
        sc = SiteConfig(version)
        sc.version = version
        if name:
            sc.siteName = name
            self.eventLog.add('update_sitename', -1, False, '', name)
        if email:
            sc.adminEmail = email

        mainDB.session.add(sc)
        mainDB.session.commit()
        self.eventLog.add('update_siteconf', -1, False, '', str(version))

    def getCurrent(self):
        return SiteConfig.query.order_by(SiteConfig.id.desc()).first()

