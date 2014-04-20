"""
"""

from flask import (Blueprint, render_template, request, flash,
        redirect, url_for)
from flask.ext.login import current_user

from noink import mainApp, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.exceptions import GroupNotFound

from noink.blueprints.admin_user import _not_auth

admin_group = Blueprint('admin_group', __name__)

@admin_group.route("/admin/group", defaults={'gid':None},
        methods=['GET', 'POST'])
@admin_group.route("/admin/group/<int:gid>", methods=['GET', 'POST'])
def admin_group_page(gid):
    """
    Renders the group page
    """
    user_db = UserDB()
    role_db = RoleDB()

    if current_user.is_authenticated() and current_user.is_active():
        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])
        all_activities = set()
        for m in role_db.get_roles(current_user):
            acts = role_db.get_activities(m.role_id)
            for act in acts:
                if acts[act]:
                    all_activities.add(act)

        can_view_groups = 'view_groups' in all_activities
        can_edit_groups = 'edit_group' in all_activities

        if is_admin or can_view_groups:
            if gid is None:
                if request.method == "POST":
                    if 'delete' in request.form:
                        gids = request.form.getlist('select')
                        for gid in gids:
                            try:
                                user_db.delete_group(int(gid))
                                flash(_('Group with ID "{0}" deleted.'.format(
                                    gid)))
                            except GroupNotFound:
                                flash(_('"{0}" group id not found!'.format(
                                    gid)), 'error')
                groups = user_db.get_all_groups()
                return render_template('list_groups.html', groups=groups,
                    state=get_state(), can_view_groups=can_view_groups,
                    can_edit_groups=can_edit_groups, title=_('All Groups'),
                    delete_button=_('Delete'), new_button=_('New'),
                    cancel_button=_('Cancel'), del_title=_('Delete Group(s)'),
                    del_warn=_('Deleting groups is a permanent action. '\
                            'Are you sure?'))
            else:
                pass

            return render_template('admin_group_page.html',
                    state=get_state())

        else:
            return _not_auth()
    else:
        return _not_auth()

