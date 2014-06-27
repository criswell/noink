"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort

from noink.entry_db import EntryDB
from noink.state import get_state
from noink.blueprints.utils import check_login_required

node = Blueprint('node', __name__)

@node.route("/node/<num>", defaults={'name':None})
@node.route("/<name>", defaults={'num':-1})
@check_login_required
def show_node(num, name):
    """
    Renders a page given it's entry id
    """
    entry = None
    url = None
    editors = None
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

    children = []
    try:
        if entry is not None:
            es = entry_db.find_editors_by_entry(entry.id)
            if len(es) > 0:
                editors = es

            if entry.children:
                children.append(entry)
                children.extend(sorted(entry.children, key=lambda e: e.weight))
            elif entry.parent_id is not None:
                te = entry_db.find_by_id(entry.parent_id)
                children.append(te)
                children.extend(sorted(te.children, key=lambda e: e.weight))
    except:
        editors = None

    #import ipdb; ipdb.set_trace()
    return render_template('node.html', entry=entry, editors=editors,
        state=get_state(), children=children)
