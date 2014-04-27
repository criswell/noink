"""
Admin events page
"""

from flask import (Blueprint, render_template, request, flash,
        redirect, url_for)
from flask.ext.login import current_user

from noink import mainApp, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.exceptions import GroupNotFound, DuplicateGroup

from noink.blueprints.admin_user import _not_auth

admin_events = Blueprint('admin_events', __name__)

@admin_events.route("/admin/events")
def event_viewer():
    """
    Render the event viewer.
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

        can_view_logs = 'view_logs' in all_activities

        if is_admin or can_view_logs:
            pass
        else:
            return _not_auth()
    else:
        return _not_auth()
