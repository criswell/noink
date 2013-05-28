
"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp
from noink.state import getState
from noink.userDB import UserDB

login = Blueprint('login', __name__)

@login.route('/login', methods=["GET", "POST"])
def login():
    if request.method == "POST" and "username" in request.form:
        username = request.form["username"]
        password = request.form["password"]
        remember = request.form.get('remember', 'no') == "yes"
        udb = UserDB()
        if udb.authenticate(username, password, remember):
            flash
