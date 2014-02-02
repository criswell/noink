"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, send_file, safe_join

from noink import mainApp

static_page = Blueprint('static', __name__, mainApp.config['STATIC_PATH'])

@static_page.route("/s/<path:filename>")
def static_show(filename):
    return send_file(safe_join(mainApp.config['STATIC_PATH'], filename))
