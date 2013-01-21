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


