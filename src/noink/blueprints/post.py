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

from flask.ext.login import current_user

post = Blueprint('post', __name__)

@post.route("/new", methods=['GET', 'POST'])
def new_post():
    """
    New posts page
    """
    return render_template('new_post.html', state=get_state())
