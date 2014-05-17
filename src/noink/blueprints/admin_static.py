"""
Admin static site page
"""

from flask import Blueprint, render_template, request, flash
from flask.ext.login import current_user

from noink import mainApp, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.event_log import EventLog
from noink.icebox import Icebox

from noink.blueprints.admin_user import _not_auth

admin_static = Blueprint('admin_static', __name__)

@admin_static.route("/admin/static", methods=['GET', 'POST'])
def static_page():
    """
    Render the administrative static page
    """
    user_db = UserDB()
    role_db = RoleDB()
    event_log = EventLog()
    icebox = Icebox()

    if current_user.is_authenticated() and current_user.is_active():
        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])
        all_activities = set()
        for m in role_db.get_roles(current_user):
            acts = role_db.get_activities(m.role_id)
            for act in acts:
                if acts[act]:
                    all_activities.add(act)

        can_admin_static = 'make_static' in all_activities
        can_admin_static_now = 'make_static_now' in all_activities

        if is_admin or can_admin_static:
            if request.method == 'POST':
                if 'sched_rebuild' in request.form:
                    event_log.add('rebuild_static', current_user.id)
                    flash(_('Full site rebuild scheduled.'))
                elif 'incr_build' in request.form:
                    icebox.generate_pages()
                    flash(_('New/updated pages generated.'))
                elif 'rebuild_now' in request.form:
                    if can_admin_static_now:
                        icebox.generate_pages(True)
                        flash(_('Full site rebuilt'))
                    else:
                        flash(_('Not authorized for full site rebuild',
                            'error'))
            return render_template('admin_static.html', state=get_state(),
                    can_admin_static=can_admin_static,
                    can_admin_static_now=can_admin_static_now,
                    title=_('Administrate Static Site'),
                    sched_rebuild_text=_('Schedule a full site rebuild'),
                    sched_rebuild_button=_('Schedule'),
                    incr_build_text=_('Perform an incremental build'),
                    incr_build_button=_('Incremental'),
                    rebuild_now_text=_('Perform a full rebuild now'),
                    rebuild_now_button=_('Rebuild'))
        else:
            return _not_auth()
    else:
        return _not_auth()
