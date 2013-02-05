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

# The name of the administrative group - Note that this field SHOULD NOT be
# changed after the database has been created, as it will not update the admin
# group in the database!
ADMIN_GROUP = "admin"

# The path to the HTML templates. Can be a relative path, or absolute.
HTML_TEMPLATES = "../default_templates"

# The secret key is used by flask for session signing
SECRET_KEY = 'Klaus Karl Kassbaum is Nick St. Nicholas'

