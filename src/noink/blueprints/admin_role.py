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
from noink.exceptions import GroupNotFound, DuplicateGroup

from noink.blueprints.admin_user import _not_auth

admin_role = Blueprint('admin_role', __name__)

@admin_role.route("/admin/role", defaults={'rid':None}, methods=['GET', 'POST'])
@admin_role.route("/admin/role/<int:rid>", methods=['GET', 'POST'])
def admin_role_page(rid):
    """
    Renders the role admin page
    """
    pass
