"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import getState

from flask.ext.login import current_user

admin = Blueprint('admin', __name__)

@node.route("/admin")
@login_required
def admin():
    """
    Renders the admin page
    """

    if current_user.is_autheticated() and current_user.is_active():
        return render_template('admin.html', state=getState())

    return render_template('admin.html', state=getState())

