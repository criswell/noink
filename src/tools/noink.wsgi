#!/usr/bin/env python

import sys
import os

# If using a virtualenv, uncomment the following, and set 'activate_this' to
# the path for your virtualenv's activation script
#  activate_this = '/path/to/virtenv/bin/activate_this.py'
#  execfile(activate_this, dict(__file__=activate_this))

# Set the following to the path where you have installed Noink's source
sys.path.append('/path/to/noink/src')

# Set the following to your Noink config file
os.environ['NOINK_CONFIGURATION'] = "/path/to/noink_config.py"

# Finally, import the mainApp as a WSGI application
from noink import mainApp as application

