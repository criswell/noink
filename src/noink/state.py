"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from noink import mainDB
from noink.data_models import SiteConfig
from noink.site_config import _SiteConfig

from flask.ext.login import current_user

class State:
    pass

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
