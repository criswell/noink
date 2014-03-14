"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB

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
        title=_('Not authorized'),
        message=_('You must be logged in as a user to access this page!'))

@admin.route("/admin/user", defaults={'uid':None}, methods=["GET", "POST"])
@admin.route("/admin/user/<int:uid>", methods=["GET", "POST"])
def admin_user(uid):
    """
    Renders the user admin page

    FIXME: Finish
    """
    user_db = UserDB()
    role_db = RoleDB()

    if current_user.is_authenticated() and current_user.is_active():
        all_groups = set(user_db.get_users_groups(current_user))
        all_roles = role_db.get_roles(current_user)
        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])
        #import ipdb; ipdb.set_trace()

        user = None
        if uid is None:
            uid = current_user.id
            user = current_user
        else:
            user = user_db.get_user(uid)

        if user is None:
            return render_template('noink_message.html', state=get_state(),
                title=_('User not found!'),
                message=_('User with ID "{0}" was not found!'.format(uid)))

        if is_admin or uid == current_user.id:
            # render the admin user page for uid user
            return render_template('admin_user.html', state=get_state(),
                user=user)

    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You are not authorized to vew this page!'))
