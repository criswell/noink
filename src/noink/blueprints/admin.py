"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import get_state
from noink.user_db import UserDB

from flask.ext.login import current_user

admin = Blueprint('admin', __name__)

@node.route("/admin")
@login_required
def admin():
    """
    Renders the admin page
    """
    user_db = UserDB()

    if current_user.is_autheticated() and current_user.is_active():
        return render_template('admin.html', 
            state=get_state(), 
            admin=user_db.in_group(current_user, mainApp.config['ADMIN_GROUP']))

    return render_template('admin.html', state=get_state())

