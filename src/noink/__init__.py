"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

mainApp = Flask("noink")
mainApp.config.from_object('noink.defaultConfig')
try:
    mainApp.config.from_envvar('NOINK_CONFIGURATION')
except:
    pass

mainDB = SQLAlchemy(mainApp)

