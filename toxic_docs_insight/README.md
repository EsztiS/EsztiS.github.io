## [ToxicDocsInsight](http://www.toxicdocsinsight.org)

### DESCRIPTION
This code is for creating an LDA topic model (Latent Dirichlet Allocation, python gensim package) to explore the [TOXIC DOCS PROJECT](http://www.toxicdocs.org) dataset via an interactive website.

The database contains a __text__ field, which is the OCR'ed result from the PDF and TIFF document images (Optical Character Recognition). This text field was pre-processed with the scripts in the scripts directory to produce the additional fields: 'words', 'non-words' and 'bow.' The text preprocessing was run on an AWS ubuntu 14.01 medium server. At the bottom are instructions on how to install the necessary packages. The requirements.txt file works on OS X El Capitan 10.11.3.

### OS X INSTRUCTIONS

#### MongoDB
To install, follow instructions on either website and then change ownership of directory.
+ <http://blog.troygrosfield.com/2011/03/21/installing-and-running-mongodb-on-a-mac/>
+ <https://docs.mongodb.org/manual/tutorial/install-mongodb-on-os-x/>
+ $ sudo chown -R `id -u` /data/db

#### Python Packages
Please use the requirements.txt. See here for instructions on working with virtual environments:
<http://flask.pocoo.org/docs/0.10/installation/>

#### Running Website
Keep directory structure (there are relative paths in the code). From the command line, in the flask directory, run run.py ($ python run.py). Copy/paste address into a browser (it is printed to console) and enjoy!

### AmazonWebServices UBUNTU 14.01 INSTRUCTIONS
If you wish to run the preprocessing steps on the raw text fields using an AWS server, requirements.txt will not work. Certain libraries need other libraries pre-installed. Here is a list of steps:

#### MongoDB:
+ <https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/>

#### Python Packages
+ $ sudo apt-get install python-pip python-dev build-essential
+ $ sudo -H pip install --upgrade pip
+ $ sudo apt-get install ipython
+ $ sudo -H pip install pymongo
+ $ sudo -H pip install nltk
 In python, >> nltk.download() to pick which corpora to install. Only need stop words. <http://blog.adlegant.com/how-to-install-nltk-corporastopwords/>

+ $ sudo apt-get install libenchant1c2a
+ sudo -H pip install pyenchant

+ $ To install SCIPY, which you need for gensim, all the following must be installed:
<http://stackoverflow.com/questions/15777836/how-to-install-scipy-on-ec2-server>
+ $ sudo pip install numpy
+ $ sudo apt-get install gfortran
+ $ sudo apt-get install libblas-dev
+ $ sudo apt-get install liblapack-dev
+ $ sudo apt-get install g++
+ $ sudo apt-get install python-scipy
+ $ sudo -H pip install gensim

+ To install pyLDAvis (there is a known bug with matplotlib that has to be fixed first)
http://stackoverflow.com/questions/25674612/ubuntu-14-04-pip-cannot-upgrade-matplotllib

+ $ sudo apt-get install libfreetype6-dev libxft-dev
+ $ sudo apt-get install python-matplotlib
+ $ sudo -H pip install pyldavis

