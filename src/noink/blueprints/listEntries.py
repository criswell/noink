"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, abort
from jinja2 import TemplateNotFound

from noink import mainApp
from noink.entryDB import EntryDB

listEntries = Blueprint('listEntries', __name__)

@listEntries.route("/", defaults={'tag':None})
@listEntries.route("/tag/<tag>")
def show(tag):
    '''
    Renders a page containing those entries defined by tag. If tag is None,
    will yield all entries.
    '''
    entryDB = EntryDB()
    if tag:
        entries = entryDB.findByTags(tag.split())
    else:
        entries = entryDB.findRecentByNum(mainApp.config['NUM_ENTRIES_PER_PAGE'][0])

    return render_template('listEntries.html', entries=entries)

