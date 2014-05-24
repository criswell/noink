Introduction
============

Noink is a dynamic web content management system which is designed to
generate static web-sites. It is written in Python, and uses the Flask
microframework.

Installation
------------

Noink requires the following Python modules:

* `Flask <http://flask.pocoo.org/>`_
* `Flask-SQLAlchemy <https://pypi.python.org/pypi/Flask-SQLAlchemy>`_
* `Flask-Bcrypt <https://pypi.python.org/pypi/Flask-Bcrypt>`_
* `Flask-Login <https://pypi.python.org/pypi/Flask-Login>`_
* `Flask-Babel <https://pypi.python.org/pypi/Flask-Babel>`_

Additionally, if you plan on developing Noink, you will need the following
modules for testing purposes:

* `Loremipsum <https://pypi.python.org/pypi/loremipsum>`_

These requirements can be installed via pip using the following commands::

    pip install -r requirements.txt
    pip install -r requirements-dev.txt

These can be installed to a virtualenv if desired.


