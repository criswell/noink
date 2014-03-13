"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, request, flash, redirect, \
                  url_for
from jinja2 import TemplateNotFound

from noink import mainApp, _
from noink.user_db import UserDB
from noink.state import get_state

login = Blueprint('login', __name__)

@login.route('/login', methods=["GET", "POST"])
def login_page():
    if request.method == "POST" and "username" in request.form:
        username = request.form["username"]
        password = request.form.get("password", None)
        remember = request.form.get('remember', 'no') == "yes"
        udb = UserDB()
        if udb.authenticate(username, password, remember):
            flash(_('%s logged in.' % username))
            return redirect(request.args.get("next") or url_for("list_entries.show"))
        else:
            flash(_('Problem logging in.'), 'error')
    return render_template('login.html', state=get_state())
