"""
Default configuration for Noink.

Sensible defaults should be set here, with any local overwrites occuring by
setting the environmental variable "NOINK_CONFIGURATION".

"""

# The database URI for whatever DB you would like to use
SQLALCHEMY_DATABASE_URI = "sqlite:////tmp/noink.db"

# The name of the administrative user - Note that this field SHOULD NOT be
# changed after the database has been created, as it will not update the admin
# user in the database!
ADMIN_USER = "admin"

# The administrative user's fullname
ADMIN_FULLNAME = "Administrator"

# The administrator's default password
# BE SURE TO CHANGE THIS AFTER YOU FIRST LOG IN
ADMIN_PASSWD = "admin"

# The name of the administrative group - Note that this field SHOULD NOT be
# changed after the database has been created, as it will not update the admin
# group in the database!
ADMIN_GROUP = "admin"

# The description of the admin group
ADMIN_GROUP_DESC = "Administrative group"

# The name of the administration role - Note that this field SHOULD NOT be
# changed after the database has been created, as it will not update the admin
# role in the database!
ADMIN_ROLE_NAME = "admin"

# The descriptiont for the administrative role - While it doesn't matter,
# necessarily, whether you change this post install or not, changing it isn't
# advised as it will have zero effect on the description in the database. If
# you wish to change it after, do so through the admin interface.
ADMIN_ROLE_DESC = "The full, site administration, role."

# The name of the default group. This is the group that all users start out in
# as their primary, unless changed. Note that this field SHOULD NOT be
# changed after the database has been created, as it will not update the
# group in the database!
DEFAULT_GROUP = 'default'

# The description of the default group
DEFAULT_GROUP_DESC = 'Default user group'

# The name of the default role. This is the role which all new users of
# the system automatically get.
DEFAULT_ROLE_NAME = 'default'

# The description of the default role.
DEFAULT_ROLE_DESC = "Default role for all users."

# The activities of the default role. These are the activities persons
# in the default role can do. Generally speaking, you wont want to
# modify this unless you know what you're doing. Any activity entries
# that are missing from this dictionary will be set to False
DEFAULT_ROLE_ACTIVITIES = {
        'edit_self': True
    }

# The top level group is the group that someone must have 'new_post' access
# to in order to make posts at the top level of the site - Note that this is
# yet another field which SHOULD NOT be changed after the database has been
# created.
TOP_LEVEL_GROUP = 'top'

# The description of the top level group
TOP_LEVEL_GROUP_DESC = "Owner of all top level posts"

# The path(s) to the HTML templates. Can be a relative path, or absolute.
HTML_TEMPLATES = [
    "blueprints/templates/default"
]

# The path to the static folders. Can be a relative path, or absolute.
STATIC_PATH = "blueprints/templates/default/static"

# The secret key is used by flask for session signing
SECRET_KEY = 'Klaus Karl Kassbaum is Nick St. Nicholas'

# This defines the number of entries per page options
NUM_ENTRIES_PER_PAGE = [
    20, 50, 100
]

# Some string which defines your post breaks in entries.
BREAK_IDENTIFIER = "<!--break-->"

# Line break tag
LINEBREAK_TAG = "<br />"

##################
## Starting Values
# The following values are for initial site setup

# This is the site name
SITE_NAME = None

# This is the site administrator's email address
SITE_ADMIN_EMAIL = None
