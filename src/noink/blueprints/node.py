"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp
from noink.entryDB import EntryDB
from noink.state import getState

node = Blueprint('node', __name__)

@node.route("/node/<num>", defaults={'name':None})
@node.route("/<name>", defaults={'num':-1})
def showNode(num, name):
    """
    Renders a page given it's entry id
    """
    entry = None
    url = None
    if num < 0 and name:
        entryDB = EntryDB()
        try:
            entry = entryDB.findByURL(name)[0]
        except:
            abort(404)
    else:
        entryDB = EntryDB()
        entry = entryDB.findById(num)
    if entry == None and url == None:
        abort(404)

    return render_template('node.html', entry=entry, state=getState())

