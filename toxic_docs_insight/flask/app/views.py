from flask import render_template, request
from app import app
from model import token_correct_stem, make_bow, hellinger
import tempfile
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

@app.route('/')

@app.route('/index.html')

@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/explore_topics')
def explore_topics():
    return render_template('explore_topics.html')

@app.route('/input')
def words_input():
    return render_template('input.html')

@app.route('/slides')
def slides():
    return render_template('slides.html')


@app.route('/output',methods=['GET','POST'])
def bow_output():
    try:
    	file = request.files['data_file']
	if file:
            text = file.stream.read().decode('utf-8')
    	if not file:
            with open('/home/ubuntu/flask/app/data.txt', 'r') as myfile:
                text=myfile.read()
    except:
        return render_template('output_error.html')
    words, non_words = token_correct_stem(text)
    bow = make_bow(words)
    vec_lda, df = hellinger(bow)

    x = int(len(df) * 0.01)
    y = list(df.sims[:x])
    files = list(df.names[:x])

    fig = plt.figure(figsize=(10,5))
    ax1 = fig.add_subplot(121, axisbg='#174785')
    ax1.set_title('Topic Probability Distribution')
    ax1.bar([i[0]+1 for i in vec_lda],[i[1] for i in vec_lda],
            color='#7FFFD4',edgecolor='none')
    ax1.set_xlim(0.,21.)
    xticks1 = ax1.xaxis.get_major_ticks()
    [i.label.set_visible(False) for i in xticks1]
    ax1.set_xlabel('Topics in Chronological Order')
    ax1.set_ylabel('Probability of Topic in Selected Document')

    ax2 = fig.add_subplot(122,axisbg='#174785')
    ax2.set_title('Hellinger Distance (top 1%)')
    ax2.plot(range(len(y)),y, color='#7FFFD4',linewidth=7)
    xticks2 = ax2.xaxis.get_major_ticks()
    [i.label.set_visible(False) for i in xticks2]
    ax2.set_xlabel('Documents Sorted by Increasing Distance')
    ax2.set_ylabel('Distance between Selected Document and Corpus')

    f = tempfile.NamedTemporaryFile(dir='/home/ubuntu/flask/app/static/tmp',
                                    suffix='.png',delete=False)
    plt.savefig(f)
    f.close
    plotPng = f.name.split('/')[-1]

    return render_template('output.html', the_result = vec_lda, plotPng=plotPng, files=files)
