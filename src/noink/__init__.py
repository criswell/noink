"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.bcrypt import Bcrypt
from flask.ext.login import LoginManager
from flask.ext.babel import Babel, gettext

import os

__version__ = "2.9.0"

try:
    __setup
except:
    __setup = False

def _parse_config():
    '''
    '''
    try:
        mainApp.config.from_envvar('NOINK_CONFIGURATION')
    except:
        mainApp.config.from_object('noink.default_config')

    mainApp.secret_key = mainApp.config['SECRET_KEY']

    # Setup our template pathing
    if mainApp.config['HTML_TEMPLATES']:
        __new_template_path = []
        from os.path import abspath
        for element in mainApp.config['HTML_TEMPLATES']:
            __new_template_path.append(abspath(element))
        mainApp.jinja_loader.searchpath = __new_template_path

def re_init():
    '''
    Call this method when you want to re-initialize as much as possible.
    '''
    _parse_config()

if not __setup:
    mainApp = Flask("noink")
    mainApp.noink_version = __version__
    _parse_config()
    mainDB = SQLAlchemy(mainApp)
    mainCrypt = Bcrypt(mainApp)
    loginManager = LoginManager()
    babel = Babel(mainApp)
    _ = gettext

    # filters
    from noink.filters import nofilter_breaksplit, nofilter_breakclean, \
            nofilter_newlines

    # blueprints
    from noink.blueprints.listentries import list_entries
    from noink.blueprints.node import node
    from noink.blueprints.static import static_page
    from noink.blueprints.login import login
    mainApp.register_blueprint(list_entries)
    mainApp.register_blueprint(node)
    mainApp.register_blueprint(static_page)
    mainApp.register_blueprint(login)

    loginManager.init_app(mainApp)

    __setup = True
