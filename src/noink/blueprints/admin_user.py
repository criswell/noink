"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request, flash
from jinja2 import TemplateNotFound

from noink import mainApp, loginManager, _
from noink.state import get_state
from noink.user_db import UserDB
from noink.role_db import RoleDB
from noink.data_models import Group, Role

from flask.ext.login import current_user

admin_user = Blueprint('admin_user', __name__)

@admin_user.route("/admin/user", defaults={'uid':None}, methods=["GET", "POST"])
@admin_user.route("/admin/user/<int:uid>", methods=["GET", "POST"])
def admin_user_page(uid):
    """
    Renders the user admin page

    FIXME: Finish
    """
    user_db = UserDB()
    role_db = RoleDB()

    if current_user.is_authenticated() and current_user.is_active():
        all_groups = set(user_db.get_users_groups(current_user))
        rolemap = role_db.get_roles(current_user)
        admin_group = user_db.get_group(mainApp.config['ADMIN_GROUP'])
        is_admin = user_db.in_group(current_user, admin_group)

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
        else:
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

        #
        # DETERMINE PERMISSIONS MORE SPECIFICALLY
        #
        can_edit_users = False
        if admin_group.id in roles_by_group:
            for rm in roles_by_group[admin_group.id]:
                acts = role_db.get_activities(rm.role)
                can_edit_users = acts.get('edit_user')

        if is_admin or uid == current_user.id:
            if request.method == "POST":
                if "form_id" in request.form:
                    if request.form['form_id'] == 'general':
                        #
                        # PASSWORD UPDATE
                        #
                        password = request.form.get('password', '')
                        pcheck = request.form.get('pcheck', '')
                        if password != '' and password is not None:
                            if password == pcheck:
                                user_db.update_password(user, password)
                                flash(_('Updated password'))
                            else:
                                flash(_('Passwords do not match!'))
                        #
                        # NAME UPDATE
                        #
                        new_name = request.form.get('name', user.name)
                        if new_name != user.name and new_name is not None:
                            # Make sure we don't have duplicate
                            exists = user_db.find_user_by_name(new_name)
                            if exists == []:
                                user.name = new_name
                                flash(_('User name updated'))
                            else:
                                flash(_('"{0}" user already exists!'.format(new_name)), 'error')
                        #
                        # FULLNAME & BIO UPDATE
                        #
                        user.fullname = request.form.get('fullname', user.fullname)
                        user.bio = request.form.get('bio', user.bio)
                        #
                        # PRIMARY GROUP
                        #
                        primary_group = request.form.get('primary_group', None)
                        if primary_group is not None and primary_group != user.primary_group.name:
                            if user_db.update_primary(user, primary_group):
                                flash(_('Updated primary group'))
                            else:
                                flash(_('Failed to update primary group'), 'error')
                        #
                        # ACTIVE
                        #
                        active = request.form.get('active', None)
                        if isinstance(active, bool):
                            if active != user.active:
                                user.active = active
                                flash(_('User active setting changed'))
                        #
                        # UPDATE DATABASE
                        #
                        user_db.update_user(user)
                    elif request.form['form_id'] == 'groups':
                        #
                        # UPDATE GROUP MEMBERSHIPS
                        #
                        if 'delete' in request.form:
                            rm_g = user_db.get_group(int(request.form['delete']))
                            if isinstance(rm_g, Group):
                                if user_db.remove_from_group(user, rm_g):
                                    flash(_('User removed from group "{0}".'.format(rm_g.name)))
                                    group = user_db.get_users_groups(user)
                                    all_groups = set(group)
                                    avail_groups = list(gs - all_groups)
                                else:
                                    flash(_('Unable to remove user "{0}" from group "{1}".'.format(user.name, rm_g.name)))
                            else:
                                flash(_('Unable to remove user "{0}" from group "{1}".'.format(user.name, request.form['delete'])))
                        elif 'add' in request.form:
                            add_g = user_db.get_group(request.form.get('add_group', None))
                            if isinstance(add_g, Group):
                                user_db.add_to_group(user, add_g)
                                group = user_db.get_users_groups(user)
                                all_groups = set(group)
                                avail_groups = list(gs - all_groups)
                                if add_g in group:
                                    flash(_('Added user to group "{0}".'.format(add_g.name)))
                                else:
                                    flash(_('Problem adding user "{0} to group "{1}"!'.format(user.name, add_g.name)), 'error')
                            else:
                                flash(_('Unable to find group "{0}"!'.format(request.form['add'])), 'error')
                    elif request.form['form_id'] == 'roles':
                        #
                        # UPDATE ROLE MEMBERSHIP
                        #
                        if 'delete' in request.form:
                            rm_r = role_db.get_role(int(request.form['delete']))
                            g = user_db.get_group(int(request.form.get('group', -1)))
                            if isinstance(rm_r, Role) and isinstance(g, Group):
                                rolemap = role_db.get_rolemapping(user, g, rm_r)
                                if rolemap is not None:
                                    role_db.revoke_role(user, g, rm_r)
                                    roles_by_group[g.id].remove(rolemap)
                                    avail_roles_by_group[g.id].append(rm_r)
                                    flash(_('Role "{0}" revoked.'.format(rm_r.name)))
                                else:
                                    flash(_('Role not assigned to user.'), 'error')
                            else:
                                flash(_('Problem finding role or group.', 'error'))
                        elif 'add' in request.form:
                            g = user_db.get_group(int(request.form.get('group', -1)))
                            r = role_db.get_role(request.form.get('add_role', None))
                            if isinstance(r, Role) and isinstance(g, Group):
                                role_db.assign_role(user, g, r)
                                rolemap = role_db.get_rolemapping(user, g, r)
                                if r in avail_roles_by_group[g.id]:
                                    avail_roles_by_group[g.id].remove(r)
                                if g.id not in roles_by_group:
                                    roles_by_group[g.id] = []
                                if rolemap not in roles_by_group[g.id]:
                                    roles_by_group[g.id].append(rolemap)
                                flash(_('Role "{0}" assigned for user "{1}" with group "{2}".'.format(r.name, user.name, g.name)))
                            else:
                                flash(_('Problem finding role or group.', 'error'))
                    else:
                        return render_template('noink_message.html',
                            state=get_state(), title=_('Form error'),
                            message=_('There was a problem identifying form elements. If this problem persists, contact your site administrator'))
            # render the admin user page for uid user
            return render_template('admin_user.html', state=get_state(),
                user=user, groups=group, avail_groups=avail_groups,
                is_admin=is_admin, role_map=rolemap, avail_roles=avail_roles,
                roles_by_group=roles_by_group, title=_('User Account'),
                avail_roles_by_group=avail_roles_by_group,
                can_edit_users=can_edit_users)

    return _not_auth()

def _not_auth():
    return render_template('noink_message.html', state=get_state(),
        title=_('Not authorized'),
        message=_('You are not authorized to vew this page!'))

@admin_user.route("/admin/user/new", methods=['GET', 'POST'])
def new_user():
    """
    Dialog for new user.
    """
    user_db = UserDB()
    role_db = RoleDB()

    if current_user.is_authenticated() and current_user.is_active():
        links = OrderedDict()

        is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])

        all_activities = set()
        for m in role_db.get_roles(current_user):
            acts = role_db.get_activities(m.role_id)
            for act in acts:
                if acts[act]:
                    all_activities.add(act)

        if 'new_user' in all_activities:
            pass
        else:
            return _not_auth()

    return _not_auth()

