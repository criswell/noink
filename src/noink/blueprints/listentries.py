"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort, request
from jinja2 import TemplateNotFound

from noink import mainApp
from noink.entry_db import EntryDB
from noink.state import get_state

list_entries = Blueprint('list_entries', __name__)

@list_entries.route("/", defaults={'tag':None})
@list_entries.route("/tag/<int:tag>")
def show(tag):
    '''
    Renders a page containing those entries defined by tag. If tag is None,
    will yield all entries.
    '''
    entryDB = EntryDB()
    if tag:
        entries = entryDB.find_by_tags([tag])
    else:
        entries = entryDB.find_recent_by_num(mainApp.config['NUM_ENTRIES_PER_PAGE'][0])

    return render_template('list_entries.html', entries=entries, state=get_state())

