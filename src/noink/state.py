"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from noink import mainDB
from noink.dataModels import SiteConfig
from noink.siteConfig import _SiteConfig

from flask.ext.login import current_user

class State:
    pass

def getState():
    """
    Returns the current state.
    """
    s = State()

    currentSiteConfig = _SiteConfig().getCurrent()
    s.noinkVersion = currentSiteConfig.version
    s.siteName = currentSiteConfig.siteName
    s.adminEmail = currentSiteConfig.adminEmail
    s.current_user = current_user

    # TODO - populate breadcrumbs here

    return s
