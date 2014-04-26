"""
Admin role page
"""

from flask import (Blueprint, render_template, request, flash,
        redirect, url_for)
from flask.ext.login import current_user

from noink import mainApp, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.exceptions import RoleNotFound

from noink.blueprints.admin_user import _not_auth

admin_role = Blueprint('admin_role', __name__)

@admin_role.route("/admin/role", defaults={'rid':None}, methods=['GET', 'POST'])
@admin_role.route("/admin/role/<int:rid>", methods=['GET', 'POST'])
def admin_role_page(rid):
    """
    Renders the role admin page
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

        can_view_roles = 'view_roles' in all_activities
        can_edit_roles = 'edit_roles' in all_activities

        if is_admin or can_view_roles:
            if rid is None:
                if request.method == 'POST':
                    rids = request.form.getlist('select')
                    for rid in rids:
                        try:
                            role_db.delete_role(int(rid))
                            flash(_('Role with ID "{0}" deleted'.format(rid)))
                        except RoleNotFound:
                            flash(_('"{0}" role id not found!'.format(rid)),
                                    'error')
                roles = role_db.get_all_roles()
                return render_template('list_roles.html', roles=roles,
                        state=get_state(), can_view_roles=can_view_roles,
                        can_edit_roles=can_edit_roles, title=_('All Roles'),
                        delete_button=_('Delete'), new_button=_('New'),
                        cancel_button=_('Cancel'),
                        del_title=_('Delete Roles(s)'),
                        del_warn=_('Deleting roles is a permanent action. '\
                                'Are you sure?'))
            else:
                pass
        else:
            return _not_auth()
    else:
        return _not_auth()
