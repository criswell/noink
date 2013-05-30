
"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request
from jinja2 import TemplateNotFound

from noink import mainApp,  _
from noink.userDB import UserDB
from noink.state import getState

login = Blueprint('login', __name__)

@login.route('/login', methods=["GET", "POST"])
def loginPage():
    if request.method == "POST" and "username" in request.form:
        username = request.form["username"]
        password = request.form["password"]
        remember = request.form.get('remember', 'no') == "yes"
        udb = UserDB()
        if udb.authenticate(username, password, remember):
            flash(_(u'%s logged in.', username))
            return rediret(request.args.get("next") or url_for("/"))
        else:
            flash(_(u'Problem logging in.'), 'error')
    return render_template('login.html', state=getState())

