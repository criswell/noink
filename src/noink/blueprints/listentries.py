"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, render_template, request

from noink import mainApp
from noink.entry_db import EntryDB
from noink.state import get_state
from noink.blueprints.utils import check_login_required

from math import ceil

list_entries = Blueprint('list_entries', __name__)

@list_entries.route("/", defaults={'tag':None})
@list_entries.route("/tag/<int:tag>")
@check_login_required
def show(tag):
    '''
    Renders a page containing those entries defined by tag. If tag is None,
    will yield all entries.
    '''
    page_num = int(request.args.get('page', 0))
    per_page = mainApp.config['NUM_ENTRIES_PER_PAGE'][0]

    entryDB = EntryDB()
    if tag:
        entries = entryDB.find_by_tags([tag])
        static_entries = None
        count = per_page
    else:
        entries = entryDB.find_recent_by_num(per_page, page_num * per_page)
        static_entries = None
        if page_num == 0:
            static_entries = entryDB.find_static()
        count = entryDB.count()

    total_pages = 0
    if count > per_page:
        total_pages = int(ceil(float(count) / float(per_page)))

    return render_template('list_entries.html', entries=entries,
        state=get_state(), page_num=page_num, total_pages=total_pages,
        static_entries=static_entries)
