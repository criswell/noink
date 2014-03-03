'''
##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END
'''

class DuplicateUser(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class DuplicateGroup(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class UserNotFound(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class EntryNotFound(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class DuplicateURL(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class UserHasNoGroups(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class DuplicateRole(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class NoRolesFound(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

