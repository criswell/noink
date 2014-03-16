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
        rolemap = role_db.get_roles(current_user)
        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])

        user = None
        group = []
        if uid is None:
            uid = current_user.id
            user = current_user
        else:
            user = user_db.get_user(uid)

        if user is None:
            return render_template('noink_message.html', state=get_state(),
                title=_('User not found!'),
                message=_('User with ID "{0}" was not found!'.format(uid)))
        elif isinstance(user, list):
            user = user[0]
            group = user_db.get_users_groups(user)

        gs = set(user_db.get_all_groups())
        avail_groups = list(gs - all_groups)

        user_roles = set()
        for m in rolemap:
            user_roles.add(m.role)

        all_roles = set(role_db.get_all_roles())
        avail_roles = list(all_roles - user_roles)

        #import ipdb; ipdb.set_trace()
        if is_admin or uid == current_user.id:
            # render the admin user page for uid user
            return render_template('admin_user.html', state=get_state(),
                user=user, groups=group, avail_groups=avail_groups,
                is_admin=is_admin, role_map=rolemap, avail_roles=avail_roles)

    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You are not authorized to vew this page!'))
