Noink CMS
=========

This is a semi-experimental rewrite of the Noink web-app in Python using Flask
and outputting static HTML.

It's currently very early in development and will progress slowly until things
start firming up.

# Goals

* Drop-in replacement for base Drupal installs (so I can retire my old Drupal
  sites).
* Be able to run dynamically but have static page generation be the main
  focus.
* ....meh?

# Setting up requirements

   pip install flask Flask-SQLAlchemy flask-bcrypt flask-login loremipsum \
               Flask-Babel

Note: loremipsum is only required for the tests.

# Obtaining and Developing Noink

Noink's primary repo is currently:

* https://bitbucket.org/criswell/noink[https://bitbucket.org/criswell/noink]

While mirrors of it may exist on Github, my personal repos and in a CVS repo on
SourceForge, these may or may not be current. When in doubt, use the Bitbucket
repo for the latest and greatest.

# Legacy Noink

The legacy Noink code can be found in the legacy/ directory. This is all Perl
code from 1998-2002. It's not intended to be ran anymore (even though I know
it still is in places) nor will it be maintained or updated. It's simply
included for historical purposes and may be removed someday.

