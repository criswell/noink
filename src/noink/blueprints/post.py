"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.entry_db import EntryDB
from noink.role_db import RoleDB

from flask.ext.login import current_user

post = Blueprint('post', __name__)

@post.route("/new", methods=['GET', 'POST'])
def new_post():
    """
    New posts page
    """
    user_db = UserDB()
    role_db = RoleDB()
    entry_db = EntryDB()

    if current_user.is_authenticated() and current_user.is_active():
        #is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])
        all_groups = set(user_db.get_users_groups(current_user))
        all_roles = role_db.get_roles(current_user)
        role_groups = set(m.group for m in all_roles)

        # The available groups are ones which they are both a part of AND which
        # they have a role in!
        avail_groups = all_groups & role_groups

        groups = []
        if current_user.primary_group in avail_groups:
            # Make sure primary group is first in the list, if it's there
            avail_groups.remove(current_user.primary_group)
            groups.append(current_user.primary_group)
        groups.extend(avail_groups)

        parent_group = None
        parent = None
        if request.values.has_key('parent'):
            parent = entry_db.find_by_id(request.values['parent'])
            parent_group = parent.group

        # If everything else fails, we default to the top level
        if parent_group is None:
            parent_group = user_db.get_group(mainApp.config['TOP_LEVEL_GROUP'])

        if parent_group in avail_groups:
            entry = None
            if request.method == "POST":
                group_used = user_db.get_group(request.form.get('group', None))
                if "preview" in request.form:
                    entry = entry_db.create_temp_entry(
                            request.form.get('title', ''),
                            request.form.get('entry', ''),
                            current_user,
                            group_used,
                            0, # FIXME - Currently unsupported
                            request.form.get('url', None),
                            request.form.get('html', False),
                            parent,
                            request.form.get('static', False))
            return render_template('new_post.html', state=get_state(), groups=groups, entry=entry)
        else:
            return render_template('noink_message.html', state=get_state(),
                title=_(u'Not authorized'),
                message=_(u'You are not authorized to post here!'))

    return render_template('noink_message.html', state=get_state(),
        title=_(u'Not authorized'),
        message=_(u'You must be logged in as a user to access this page!'))
