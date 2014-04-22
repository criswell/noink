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
    """
    Inner config parser.
    """
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
    """
    Call this method when you want to re-initialize as much as possible.
    """
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

    # custom tests
    from noink.custom_tests import is_editable, is_deletable

    # blueprints
    from noink.blueprints.listentries import list_entries
    from noink.blueprints.node import node
    from noink.blueprints.static import static_page
    from noink.blueprints.login import login
    from noink.blueprints.logout import logout
    from noink.blueprints.admin import admin
    from noink.blueprints.admin_user import admin_user
    from noink.blueprints.post import post
    from noink.blueprints.admin_group import admin_group
    from noink.blueprints.admin_role import admin_role
    mainApp.register_blueprint(list_entries)
    mainApp.register_blueprint(node)
    mainApp.register_blueprint(static_page)
    mainApp.register_blueprint(login)
    mainApp.register_blueprint(logout)
    mainApp.register_blueprint(admin)
    mainApp.register_blueprint(admin_user)
    mainApp.register_blueprint(post)
    mainApp.register_blueprint(admin_group)
    mainApp.register_blueprint(admin_role)

    loginManager.init_app(mainApp)

    __setup = True
