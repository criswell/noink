"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

app.config.from_object('noink.defaultConfig')
app.config.from_envvar('NOINK_CONFIGURATION')

mainApp = Flask("noink")
mainDB = SQLAlchemy(mainAPP)

