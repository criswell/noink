"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import get_state
from noink.user_db import UserDB

from flask.ext.login import current_user, login_required

admin = Blueprint('admin', __name__)

@admin.route("/admin")
@login_required
def admin_page():
    """
    Renders the admin page
    """
    user_db = UserDB()

    if current_user.is_autheticated() and current_user.is_active():
        return render_template('admin.html', 
            state=get_state(), 
            admin=user_db.in_group(current_user, mainApp.config['ADMIN_GROUP']))

    # XXX Is this even necessary? Will we ever get here with login_required?
    return render_template('noink_message.html', state=get_state(),
        title=_(u'Not authorized'),
        message=_(u'You must be logged in as a user to access this page!'))

