"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request
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

        avail_roles = role_db.get_all_roles()
        avail_roles_by_group = dict()
        for g in gs:
            avail_roles_by_group[g.id] = list(avail_roles)

        roles_by_group = dict()
        for rm in rolemap:
            if rm.group_id not in roles_by_group:
                roles_by_group[rm.group_id] = []

            if rm.group_id in avail_roles_by_group:
                if rm.role in avail_roles_by_group[rm.group_id]:
                    avail_roles_by_group[rm.group_id].remove(rm.role)

            roles_by_group[rm.group_id].append(rm)

        if is_admin or uid == current_user.id:
            if request.method == "POST":
                if "form_id" in request.form:
                    if request.form['form_id'] == 'general':
                        print("General")
                    elif request.form['form_id'] == 'groups':
                        print("Groups")
                    elif request.form['form_id'] == 'roles':
                        print("Roles")
                    else:
                        return render_template('noink_message.html',
                            state=get_state(), title=_('Form error'),
                            message=_('There was a problem identifying form elements. If this problem persists, contact your site administrator'))
                import ipdb; ipdb.set_trace()
            # render the admin user page for uid user
            return render_template('admin_user.html', state=get_state(),
                user=user, groups=group, avail_groups=avail_groups,
                is_admin=is_admin, role_map=rolemap, avail_roles=avail_roles,
                roles_by_group=roles_by_group,
                avail_roles_by_group=avail_roles_by_group)

    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You are not authorized to vew this page!'))
