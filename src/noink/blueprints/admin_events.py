"""
Admin events page
"""

from flask import Blueprint, render_template, request
from flask.ext.login import current_user

from noink import mainApp, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.event_log import EventLog

from noink.blueprints.admin_user import _not_auth

from math import ceil

admin_events = Blueprint('admin_events', __name__)

@admin_events.route("/admin/events")
def event_viewer():
    """
    Render the event viewer.
    """
    page_num = int(request.args.get('page', 0))
    per_page = int(request.args.get('per_page', 20))
    user_db = UserDB()
    role_db = RoleDB()
    event_log = EventLog()

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
            events = event_log.find_recent_by_num(per_page, page_num * per_page)
            count = event_log.count()

            total_pages = 0
            if count > per_page:
                total_pages = int(ceil(float(count) / float(per_page)))

            return render_template('admin_events.html', events=events,
                state=get_state(), page_num=page_num, per_page=per_page,
                title=_('Event log'), total_pages=total_pages)
        else:
            return _not_auth()
    else:
        return _not_auth()
