"""

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

"""

from noink import mainApp

@mainApp.template_filter('nofilter_breakSplit')
def nofilter_breakSplit(s):
    """
    Given a string, will return an array with that string broken into segments
    on the BREAK identifier defined in config.

    @param s: The string.

    @return: An array containing the segments of the split string.
    """
    return s.split(mainApp.config['BREAK_IDENTIFIER'])

