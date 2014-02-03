
"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request, flash, redirect, \
                  url_for
from jinja2 import TemplateNotFound

from noink import mainApp, _
from noink.user_db import UserDB
from noink.state import get_state
from flask.ext.login import current_user

logout = Blueprint('logout', __name__)

@logout.route('/logout')
def logout_user():
    udb = UserDB()
    if current_user.is_authenticated() and current_user.is_active():
        if udb.logout(current_user):
            flash(_(u'Logged out.'))
            return redirect(request.args.get("next") or url_for("list_entries.show"))

    return render_template('noink_message.html', state=get_state(),
        title=_(u'Problem logging out'),
        message=_(u'There was a problem logging you out (were you logged in?)'))
