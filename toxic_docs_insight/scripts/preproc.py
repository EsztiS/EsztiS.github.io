"""
Class for pre-processing text from MongoDB of toxic_docs for use in topic modeling.
Mongo server should be running.
Initialize with database name and collection name.
Tokenize and correct for saving into database as new fields.
"""

import pymongo
import nltk
import enchant

class preproc():

    def __init__(self,dbname,clxn):
    # Initialize with database and collection names as strings.
    # Load references for use in cleaning.

        self.con = pymongo.MongoClient()
        self.db = self.con[dbname]
        self.clxn = self.db[clxn]
        self.cursor = self.clxn.find({ },no_cursor_timeout=True)
        print 'Number of documents: %i' %self.cursor.count()

        self.dict_en = enchant.Dict('en_US')
        with open('../data/BestLcOCRRules.csv') as f:
            rows = [line.split(',') for line in f]
            self.OCR_common = { row[0]:row[1] for row in rows }
        self.tzer = nltk.RegexpTokenizer(r"\w+(?=n't)|n't|\w+(?=')|'\w+|\w+|-")
        self.stopEng = set(nltk.corpus.stopwords.words('english'))
        self.p_stemmer = nltk.PorterStemmer()

    def token_correct_stem(self):
        """
    Tokenize based on nltk RegexpTokenizer.
    Split into words and non-words based on PyEnchant English dict and being alphanumeric.
    Change any common mistakes from OCR process.
    Filter out stop words.
    Write to new fields 'words' and 'non_words' in initialized database.
    """
        for d in self.cursor:

            tokens = self.tzer.tokenize(d['text'])
            words = [t for t in tokens if self.dict_en.check(t.lower())]
            non_words = [t for t in tokens if not self.dict_en.check(t.lower()) and len(t)>1]
            words += [self.OCR_common[str(nw)] for nw in non_words if str(nw) in self.OCR_common]
            filtered = filter(lambda word: word.lower() not in self.stopEng, words)
            stemmed = [self.p_stemmer.stem(i.lower()) for i in filtered]

            self.clxn.update_one(
                                 { 'original_filename' : d['original_filename'] },
                                 { '$set' : {'words' : stemmed, 'non_words' : non_words } } )
