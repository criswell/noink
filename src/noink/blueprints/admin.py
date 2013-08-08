"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp, _
from noink.state import getState

admin = Blueprint('admin', __name__)

@node.route("/admin")
def admin():
    """
    Renders the admin page
    """

    return render_template('admin.html', state=getState())

