"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
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

    if current_user.is_authenticated() and current_user.is_active():
        #is_admin = user_db.in_group(current_user, mainApp.config['ADMIN_GROUP'])
        all_groups = set(user_db.get_users_groups(current_user))
        all_roles = role_db.get_roles(current_user)
        role_groups = set(m.group for m in all_roles)

        # The available groups are ones which they are both a part of AND which
        # they have a role in!
        avail_groups = list(all_groups & role_groups)

    return render_template('new_post.html', state=get_state(), groups=avail_groups)
