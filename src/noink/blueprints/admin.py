"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from collections import OrderedDict

from flask import (Blueprint, render_template, url_for)

from noink import mainApp, _
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
    role_db = RoleDB()

    if current_user.is_authenticated() and current_user.is_active():
        links = OrderedDict()

        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])

        roles_by_group = {}
        all_roles = set()
        all_activities = set()
        for m in role_db.get_roles(current_user):
            if m.group_id not in roles_by_group:
                roles_by_group[m.group_id] = set()
            roles_by_group[m.group_id].add(m.role_id)
            all_roles.add(m.role_id)
            acts = role_db.get_activities(m.role_id)
            for act in acts:
                if acts[act]:
                    all_activities.add(act)

        personal_and_group = _('Personal and Group Settings')
        links[personal_and_group] = []
        #
        # Personal User and Group items
        #
        if 'edit_self' in all_activities:
            links[personal_and_group].append({
                    'url' : url_for("admin_user.admin_user_page"),
                    'text' : _('My User Settings'),
                    'desc' : _('Adjust your personal user settings.')
                })
        if 'new_user' in all_activities:
            links[personal_and_group].append({
                    'url' : url_for("admin_user.new_user"),
                    'text' : _('Create New User'),
                    'desc' : _('Create a new user.')
                })

        entries = _('Entries')
        links[entries] = []
        #
        # Entries
        #
        if 'new_post' in all_activities:
            links[entries].append({
                    'url' : url_for("post.new_post"),
                    'text' : _('New entry'),
                    'desc' : _('Create a new entry')
                })

        return render_template('admin.html', state=get_state(), links=links,
                is_admin=is_admin, title=_('Admin'))

    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You must be logged in as a user to access this page!'))

