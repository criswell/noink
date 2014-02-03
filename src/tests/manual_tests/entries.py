'''

##BOILERPLATE_COPYRIGHT
##BOILERPLATE_COPYRIGHT_END

'''

from loremipsum import get_paragraphs, get_sentences

from random import randint, sample

entries = []

all_tags = ['Foo', 'Bar', 'Snaz', 'Loop', 'Core', 'Nugget', 'Piddle', 'Snappy']

for i in range(randint(50, 90)):
    title = get_sentences(1)[0]
    p = get_paragraphs(randint(4, 20))
    index = randint(1,3)
    entry = '\n\n'.join(p[0:index])
    entry = entry + "<!--break-->" + '\n\n'.join(p[index:])
    weight = randint(-5, 5)
    url = None
    if randint(0,1):
        url = '_'.join(get_sentences(1)[0][:-1].split())

    tags = None
    if randint(0,5) > 1:
        tags = sample(all_tags, randint(1, len(all_tags)-1))
        tags.append('Everything')
    e = ( "%s (%d)" % (title, i), entry, weight, url, tags, False)
    entries.append(e)


