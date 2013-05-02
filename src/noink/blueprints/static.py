"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT

"""

from flask import Blueprint, send_file, safe_join

from noink import mainApp

staticPage = Blueprint('static', __name__, mainApp.config['STATIC_PATH'])

@staticPage.route("/s/<path:filename>")
def staticShow(filename):
    print mainApp.config['STATIC_PATH']
    print filename
    return send_file(safe_join(mainApp.config['STATIC_PATH'], filename))

