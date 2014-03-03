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

For general installation, use the Python requirements found in

    requirements.txt

For development and testing, additionally use those found in

    requirements-dev.txt

These can be installed via pip using the following commands:

    pip install -r requirements.txt
    pip install -r requirements-dev.txt

# Obtaining and Developing Noink

Noink's primary repo is currently:

* [bitbucket.org/criswell/noink](https://bitbucket.org/criswell/noink)

While mirrors of it may exist on Github, my personal repos and in a CVS repo on
SourceForge, these may or may not be current. When in doubt, use the Bitbucket
repo for the latest and greatest.

# Legacy Noink

The legacy Noink code can be found in the legacy/ directory. This is all Perl
code from 1998-2002. It's not intended to be ran anymore (even though I know
it still is in places) nor will it be maintained or updated. It's simply
included for historical purposes and may be removed someday.

