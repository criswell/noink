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

@mainApp.template_filter('nofilter_breakClean')
def nofilter_breakClean(s):
    """
    Given a string, will return a string with all BREAK identifiers cleaned.

    @param s: The string.

    @return: A string which has BREAK purged.
    """
    return ' '.join(s.split(mainApp.config['BREAK_IDENTIFIER']))

@mainApp.template_filter('nofilter_newLines')
def nofilter_newLines(s):
    """
    Given a string, will replace all new lines with line break tags.

    @param s: The string

    @return: A string with new lines replaced with line break tags
    """
    return mainApp.config['LINEBREAK_TAG'].join(s.split('\n'))
