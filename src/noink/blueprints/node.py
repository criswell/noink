"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp
from noink.entry_db import EntryDB
from noink.state import get_state

node = Blueprint('node', __name__)

@node.route("/node/<num>", defaults={'name':None})
@node.route("/<name>", defaults={'num':-1})
def show_node(num, name):
    """
    Renders a page given it's entry id
    """
    entry = None
    url = None
    if num < 0 and name:
        entry_db = EntryDB()
        try:
            entry = entry_db.find_by_URL(name)[0]
        except:
            abort(404)
    else:
        entry_db = EntryDB()
        entry = entry_db.find_by_id(num)
    if entry == None and url == None:
        abort(404)

    return render_template('node.html', entry=entry, state=get_state())
