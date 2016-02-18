"""
Create Latent Dirichlet Model with a specified number of topics.
Create pyLDAvis visualization of topics and topic words.
Mongo server should be running.
"""

import pymongo
import gensim as gs
import pyLDAvis.gensim
import logging

class model():

    def __init__(self,dbname,clxn):
        # Initialize with database name and collection.
        self.con = pymongo.MongoClient()
        self.db = self.con[dbname]
        self.clxn = self.db[clxn]

    def create_bow(self):
        # Create bags of words for each document, up-dating dictionary if necessary.
        # Returns dictionary.
        dictionary = gs.corpora.Dictionary.load('../data/dictionary.dic')
        cursor = self.clxn.find({'words':{'$exists':1}, 'bow':{'$exists':0}},no_cursor_timeout=True)
        if cursor.count() > 0:
            for d in cursor:
                bow = dictionary.doc2bow([w for w in d['words']
                                         if (w.isdigit() and len(w) == 4) or
                                         (not w.isdigit() and len(w)>2)],
                                         allow_update = True)
                self.clxn.update_one(
                { 'original_filename' : d['original_filename'] },
                { '$set' : {'bow' : bow } } )
            gs.corpora.Dictionary.save(dictionary,'../data/dictionary.dic')
        return dictionary

    def create_model(self, n_topics):
        # Create model with specified number of topics. Enter as integer.
        # Returns corpus, lda_model needed for visualization
        logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

        dictionary = gs.corpora.Dictionary.load('../data/dictionary.dic')

        cursor = self.clxn.find({'bow' : {'$exists' : 1 } }, no_cursor_timeout=True)
        corpus = [d['bow'] for d in cursor]

        lda_model = gs.models.ldamodel.LdaModel(corpus=corpus, id2word = dictionary, num_topics = n_topics, update_every = 1, chunksize = 100, passes = 50)
        lda_corpus = lda_model[corpus]

        index = gs.similarities.MatrixSimilarity(lda_corpus, num_features = n_topics)

        lda_model.save('lda_model_'+str(n_topics)+'.model')
        index.save('simIndex_'+str(n_topics)+'.index')
        gs.corpora.mmcorpus.MmCorpus.serialize('corpus.mm',corpus)

        return corpus, lda_model, index

    def visualize(self, dictionary, corpus, lda_model, n_topics):
        # Visualizes model. Write to html file.
        data = pyLDAvis.gensim.prepare(lda_model, corpus, dictionary)
        pyLDAvisHTML = pyLDAvis.prepared_data_to_html(data)
        f = open('pyLDAvis_'+str(n_topics)+'.html','w')
        f.write(pyLDAvisHTML)
        f.close()





