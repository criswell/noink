"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, request, redirect, \
        url_for, flash

from noink import mainApp, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.entry_db import EntryDB
from noink.role_db import RoleDB
from noink.custom_tests import is_deletable

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
        int(request.form.get('weight', 0)),
        purl,
        bool(request.form.get('html', False)),
        parent,
        bool(request.form.get('static', False)))

def update_entry_object(entry):
    """
    Update, in-place, an entry object based upon form submissions.
    """
    entry.entry = request.form.get('entry', '')
    entry.title = request.form.get('title', '')
    entry.html = bool(request.form.get('html', False))
    entry.static = bool(request.form.get('static', False))
    purl = request.form.get('url', None)
    if purl == '':
        purl = None
    entry.url = purl
    entry.weight = int(request.form.get('weight', 0))
    return entry

def not_authorized():
    return render_template('noink_message.html', state=get_state(),
                title=_('Not authorized'),
                message=_('You are not authorized to post here!'))

def _edit_post(eid=None):
    """
    Edit a post
    """
    # FIXME - This method has kind of gotten monsterous. Refactor.
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
            #avail_groups.remove(current_user.primary_group)
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
                if eid is None:
                    if request.method == "POST":
                        entry = process_entry_object(parent)
                        if "tags" in request.form:
                            tags = [x.strip() for x in
                                    request.form['tags'].split(',') if x != '']
                        if "submit" in request.form:
                            entry_db.add_entry_object(entry)
                            if len(tags) > 0:
                                entry_db.add_tag(tags, entry)
                            return redirect(url_for('node.show_node',
                                num=entry.id))
                else:
                    entry = entry_db.find_by_id(eid)
                    if entry is None:
                        return render_template('noink_message.html',
                            state=get_state(),
                            title=_('Entry not found!'),
                            message=_(
                                'The entry "{0}" was not found!'.format(eid)))
                    if request.method == "POST":
                        entry = update_entry_object(entry)
                        if "tags" in request.form:
                            tags = [x.strip() for x in
                                    request.form['tags'].split(',') if x != '']
                        if "submit" in request.form:
                            entry_db.update_entry(entry)
                            entry_db.update_editor(current_user, entry)
                            if len(tags) > 0:
                                entry_db.add_tag(tags, entry)
                            return redirect(url_for('node.show_node',
                                num=entry.id))
                    else:
                        for tm in entry.tagmap:
                            tags.append(tm.tag.tag)

                return render_template('new_post.html', state=get_state(),
                    groups=groups, entry=entry, tags=tags, is_edit=True,
                    title=_('New Post'), submit_button=_('Submit'),
                    preview_button=_('Preview'))
            else:
                return not_authorized()
        else:
            return not_authorized()

    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You must be logged in as a user to access this page!'))

@post.route("/new", methods=['GET', 'POST'])
def new_post():
    """
    New posts page
    """
    return _edit_post()

@post.route("/edit/<num>", methods=['GET', 'POST'])
def edit(num):
    """
    Edit post page
    """
    if num is None:
        return render_template('noink_message.html', state=get_state(),
            title=_('No entry specified!'),
            message=_('You have not supplied an entry to edit.'))

    return _edit_post(num)

@post.route("/delete/<num>", methods=['GET', 'POST'])
def delete_post(num):
    """
    Delete a post
    """
    if num is None:
        return render_template('noink_message.html', state=get_state(),
            title=_('No entry specified!'),
            message=_('You have not supplied an entry to delete.'))

    entry_db = EntryDB()

    entry = entry_db.find_by_id(num)

    if entry is None:
        return render_template('noink_message.html', state=get_state(),
            title=_('Entry not found!'),
            message=_('The entry "{0}" was not found!'.format(num)))

    if not is_deletable(entry):
        return render_template('noink_message.html', state=get_state(),
            title=_('Unable to delete entry!'),
            message=_('You do not have permission to delete this entry!'))

    if request.method == 'POST':
        if "delete" in request.form:
            entry_db.delete(entry)
            flash(_('Entry "{0}" deleted!'.format(num)))
            return redirect(url_for('list_entries.show'))
        elif "cancel" in request.form:
            return  redirect(url_for("node.show_node", num=num))

    return render_template('delete_post.html', state=get_state(),
            entry=entry, is_edit=True)

