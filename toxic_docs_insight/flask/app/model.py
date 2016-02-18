"""
This script preprocesses a new text file in order to find distance to rest of documents in corpus. Uses same code as for scripts/model.py.
"""

import enchant
import nltk
import gensim as gs
from app import app
import pandas as pd
import numpy as np
import os
from pymongo import MongoClient
conn = MongoClient('127.0.0.1', 27017)
db = conn['toxic_docs']

# Loading dictionaries and references for preprocessing
dict_en = enchant.Dict('en_US')
tokenizer = nltk.RegexpTokenizer(r"\w+(?=n't)|n't|\w+(?=')|'\w+|\w+|-")
p_stemmer = nltk.PorterStemmer()
stopEng = set(nltk.corpus.stopwords.words('english'))

# Load dictionary and model created from preproc.py and model.py in scripts folder.
dictionary = gs.corpora.Dictionary.load(os.path.abspath('../data/dictionary.dic'))
lda_model = gs.models.ldamodel.LdaModel.load(os.path.abspath('../data/lda_model_20.model'))

with open(os.path.abspath('../data/BestLcOCRRules.csv')) as f:
    rows = [line.split(',') for line in f]
    OCR_common = { row[0]:row[1] for row in rows }

def token_correct_stem(text):
    # Same code as for function in scripts/model.py:token_correct_stem

    tokens = tokenizer.tokenize(text)
    words = [t for t in tokens if dict_en.check(t.lower())]
    non_words = [t for t in tokens if not dict_en.check(t.lower) and len(t)>1]

    words += [OCR_common[str(nw)] for nw in non_words if str(nw) in OCR_common]

    filtered = filter(lambda word: word.lower() not in stopEng, words)
    stemmed = [p_stemmer.stem(i.lower()) for i in filtered]

    return stemmed, non_words

def make_bow(words):
    # Same code as function for scripts/model.py:create_bow
    bow = dictionary.doc2bow([w for w in words
                                         if (w.isdigit() and len(w) == 4) or
                                         (not w.isdigit() and len(w)>2)],
                                         allow_update = True)
    return bow

def hellinger(bow):
    # Calculates Hellinger distance between new text and documents in corpus
    cursor = db.documents.find( {'bow' : {'$exists' : 1 } } )
    names = []
    corpus = []

    # create dataframe of paths for documents in corpus
    for d in cursor:
        names.append(d['original_filename'])
        corpus.append(d['bow'])
    df = pd.DataFrame(data=names,columns=['names'])

    # create vector of topic distribution in new text
    vec_lda = lda_model[bow]

    # calculate topic distribution for each document in corpus (p) and topic distribution for new document (q) based on formula h^2(p,q) = 1/2 * (sum(sqrt(dP) - sqrt(dQ))^2 )
    p = np.sqrt(gs.matutils.corpus2dense(lda_model[corpus], lda_model.num_topics).T)
    q = np.sqrt(gs.matutils.sparse2full(vec_lda, lda_model.num_topics))
    distances = np.sqrt(0.5 * np.sum((q - p)**2, axis=1))

    # put distances into dataframe with filepaths and sort in ascending order
    df['distances'] = distances
    df.sort_values('distances',ascending=True,inplace=True)

    # multiply by 100 to get percentages rather than probability b/w 0 and 1
    vec_lda = [(i[0]+1,round(i[1]*100,1)) for i in vec_lda]

    return vec_lda, df

def allowed_file(filename):
    # only accept txt files for comparison
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in set(['txt'])

