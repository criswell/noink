"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request, redirect, \
        url_for, flash
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.entry_db import EntryDB
from noink.role_db import RoleDB
from noink.exceptions import DuplicateURL

from flask.ext.login import current_user

post = Blueprint('post', __name__)

def process_entry_object(parent):
    '''
    Return an entry object. Does not add to db
    '''
    user_db = UserDB()
    entry_db = EntryDB()
    group_used = user_db.get_group(request.form.get('group', None))
    purl = request.form.get('url', None)
    if purl is not None:
        t = entry_db.find_by_URL(purl)
        if len(t) > 0:
            flash(_("'{0}' URL is already in use!".format(purl)))
            purl = None
    return entry_db.create_temp_entry(
        request.form.get('title', ''),
        request.form.get('entry', ''),
        current_user,
        group_used,
        0, # FIXME - Currently unsupported
        purl,
        request.form.get('html', False),
        parent,
        request.form.get('static', False))

def not_authorized():
    return render_template('noink_message.html', state=get_state(),
                title=_('Not authorized'),
                message=_('You are not authorized to post here!'))

@post.route("/new", methods=['GET', 'POST'])
def new_post():
    """
    New posts page
    """
    user_db = UserDB()
    role_db = RoleDB()
    entry_db = EntryDB()

    if current_user.is_authenticated() and current_user.is_active():
        all_groups = set(user_db.get_users_groups(current_user))
        all_roles = role_db.get_roles(current_user)
        role_groups = set(m.group for m in all_roles)
        role_by_groups = dict(((m.group, role_db.get_activities(m.role))
            for m in all_roles))

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
        if 'parent' in request.values:
            parent = entry_db.find_by_id(request.values['parent'])
            parent_group = parent.group

        # If everything else fails, we default to the top level
        if parent_group is None:
            parent_group = user_db.get_group(mainApp.config['TOP_LEVEL_GROUP'])

        if parent_group in avail_groups and parent_group in role_by_groups:
            if role_by_groups[parent_group].get('new_post', False):
                entry = None
                tags = []
                if request.method == "POST":
                    entry = process_entry_object(parent)
                    if "tags" in request.form:
                        tags = [x.strip() for x in
                                request.form['tags'].split(',') if x != '']
                    if "submit" in request.form:
                        entry_db.add_entry_object(entry)
                        if len(tags) > 0:
                            entry_db.add_tag(tags, entry)
                        return redirect(url_for('node.show_node', num=entry.id))
                return render_template('new_post.html', state=get_state(),
                    groups=groups, entry=entry, tags=tags, is_edit=True)
            else:
                return not_authorized()
        else:
            return not_authorized()

    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You must be logged in as a user to access this page!'))
