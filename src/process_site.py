"""
Should be run from cron, at whatever interval you deem necessary
"""

from noink.icebox import Icebox

i = Icebox()
i.generate_pages()

