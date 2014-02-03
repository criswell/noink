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

@admin.route("/admin")
def admin_page():
    """
    Renders the admin page
    """
    user_db = UserDB()

    if current_user.is_authenticated() and current_user.is_active():
        return render_template('admin.html', 
            state=get_state(), 
            admin=user_db.in_group(current_user, mainApp.config['ADMIN_GROUP']))

    return render_template('noink_message.html', state=get_state(),
        title=_(u'Not authorized'),
        message=_(u'You must be logged in as a user to access this page!'))

@admin.route("/admin/user", defaults={'uid':None}, methods=["GET", "POST"])
@admin.route("/admin/user/<int:uid>", methods=["GET", "POST"])
def admin_user(uid):
    """
    Renders the user admin page

    FIXME: Finish
    """
    user_db = UserDB()

    if current_user.is_authenticated() and current_user.is_active():
        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])

        if uid is None and is_admin:
            # render the administrate users interface
            pass

        if uid is None:
            uid = current_user.id

        if is_admin or uid == current_user.id:
            # render the admin user page for uid user
            pass

    return render_template('noink_message.html', state=get_state(),
        title=_(u'Not authorized'),
        message=_(u'You are not authorized to vew this page!'))
