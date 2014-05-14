"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from noink.site_config import _SiteConfig

from flask.ext.login import current_user

class State:
    __borg_state = {}

    def __init__(self):
        self.__dict__ = self.__borg_state

        try:
            self._setup
        except AttributeError:
            self._setup = False

        if not self._setup:
            self.icebox = False
            self._setup = True

def get_state():
    """
    Returns the current state.
    """
    s = State()

    currentSiteConfig = _SiteConfig().getCurrent()
    s.noink_version = currentSiteConfig.version
    s.site_name = currentSiteConfig.site_name
    s.admin_email = currentSiteConfig.admin_email
    s.current_user = current_user

    # TODO - populate breadcrumbs here

    return s
