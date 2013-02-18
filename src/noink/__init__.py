"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

import os

try:
    __setup
except:
    __setup = False

def _parseConfig():
    '''
    '''
    try:
        mainApp.config.from_envvar('NOINK_CONFIGURATION')
    except:
        mainApp.config.from_object('noink.defaultConfig')

    mainApp.secret_key = mainApp.config['SECRET_KEY']

    # Setup our template pathing
    if mainApp.config['HTML_TEMPLATES']:
        __newTemplatePath = []
        from os.path import abspath
        for element in mainApp.config['HTML_TEMPLATES']:
            __newTemplatePath.append(abspath(element))
        mainApp.jinja_loader.searchpath = __newTemplatePath

def reInit():
    '''
    Call this method when you want to re-initialize as much as possible.
    '''
    _parseConfig()

if not __setup:
    mainApp = Flask("noink")
    _parseConfig()
    mainDB = SQLAlchemy(mainApp)

    # filters
    from noink.filters import nofilter_breakSplit, nofilter_breakClean, \
            nofilter_newLines

    # blueprints
    from noink.blueprints.listEntries import listEntries
    from noink.blueprints.node import node
    mainApp.register_blueprint(listEntries)
    mainApp.register_blueprint(node)

    __setup = True

