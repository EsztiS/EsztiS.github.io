'''
Python class for quickly checking status of webpage links and counting word frequencies. 
'''

''' Import necessary packages'''
import requests
import re
from bs4 import BeautifulSoup
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import chain
import numpy as np
%matplotlib inline
plt.style.use('ggplot')

'''Temporary list of words to possibly exclude from frequency count'''
commons = ['a','aboard','about','above','absent','across','after','against','all','along',
           'alongside','amid','amidst','among','an','and','anti','around','as','at','atop',
           'backward','forward',
           'bar','barring','before','behind','below','beneath','beside','besides' ,'between',
           'beyond','but','by','circa','counting','concerning','considering','despite','down',
           'during','except','excepting','excluding','following','for','from','given','gone',
           'in','inside','instead','into','is','less','like','mid','minus','near','next','of',
           'off','on','onto','opposite','out','outside','over','past','pending','per','plus',
           'pro','regarding','regardless' ,'round','save','saving','since','than','that','the',
           'their','there','through','throughout','till','times','to','toward','towards',
           'under','underneath','unlike','until','up','upon','versus' ,'via','with','within',
           'without','worth','',' ','will','this','say','other']
bad = ['|','','/','\\',u'\u2014']

class wsite(object):
    def __init__(self, url):
        self.url = url
    
    def get_text(self, console='no'):
        # Works on any browser
        agent = {
                'Firefox' : 'Mozilla/5.0', 
                'Explorer': 'Windows NT 6.1',
                'KHTML'   : 'AppleWebKit/537.36',
                'Chrome'  : 'Chrome/41.0.2228.0',
                'Safari'  : 'Safari/537.36'
                }
        a = True
        for i in agent.values(): 
            while a:
                p = requests.get(self.url, headers = {'User-Agent': i})
                print 'Status Code: ',p.status_code
                text = BeautifulSoup(p.text)
                if text.title.get_text() == 'Not Acceptable!':
                    continue
                else:
                    a = False
        self.text = text
        if console == 'yes':
            return text
    
    def cache(self, cache_file):
        # To work on offline. Note utf-8.
        with open(cache_file, 'w') as f:
            f.write(self.text.encode('utf-8'))
                    
    def pullSites(self, console='no'):
        # Get full path to external links and don't count internal links
        atext = self.text.find_all('a',href=re.compile('^[^#]'))
        self.atext = atext
        orig = re.search('www\.(.*)\.', self.url).group(1) 
        allsites=[]
        for i in range(len(atext)):
            if 'http' in atext[i].attrs['href']:
                if orig not in atext[i].attrs['href']:
                    allsites.append(atext[i].attrs['href'])
        self.allsites = allsites
        if console == 'yes':
            return allsites
    
    def removeDuplicates(self, console='no'):
        # Remove duplicate links
        new = []
        for i in self.allsites:
            if i not in new:
                new.append(i)
        self.new = new
        if console == 'yes':
            return new
    
    def checkStatus(self, console='no'):
        # Get status of url link and sort accordingly
        IL = [] # informational
        OK = [] # success
        RD = [] # re-directed
        CE = [] # client error
        SE = [] # server error
        broken = []
        for i in self.new:
            try:
                resp = requests.head(i)
                if resp.status_code >= 500:
                    SE.append(i)
                elif resp.status_code >= 400:
                    CE.append(i)
                elif resp.status_code >= 300:
                    RD.append(i)
                elif resp.status_code >= 200:
                    OK.append(i)
                elif resp.status_code >= 100:
                    IL.append(i)
            except:
                broken.append(i)
        urls = [IL, OK, RD, CE, SE, broken]
        self.urls = urls
        if console == 'yes':
            return urls
    
    def plt_status_codes(self, fs=12, wh=0.35):
        # Plot status codes of urls on website
        hgh = map(lambda x: len(x), self.urls)
        ind = np.arange(len(self.urls))
        names = ['Info', 'Ok', 'Redirected', 'Client E', 'Server E', 'Broken']
        total = sum(hgh)
        percents = map(lambda x: round((float(x)/float(total))*100,1), hgh)
        
        fig = plt.figure(figsize=(7,7),dpi=600)
        plt.bar(ind,hgh)
        plt.ylabel('Count', fontsize = fs)
        plt.title('URL Status Codes',fontsize=fs+4)
        plt.xticks(ind+0.6/2,names,fontsize = fs)
        plt.text(4,max(hgh)/2,'Total Sites: '+str(total), fontsize=fs)
        for i in range(len(percents)):
            plt.text(i + 0.3, hgh[i] + 0.1, str(percents[i])+'%')
        plt.savefig('StatusCodes.png',bbox_inches='tight')
        
    def counting(self, console = 'no'):
        # Count the frequencies of all words on page
        apdict = {i: i.find_next_sibling(text=True) for i in self.atext}
        counted = {}
        comb_list = list(chain(urls[1],urls[2]))
        for i,j in apdict.items():
            if i['href'] in comb_list and j != None:
                paragraph = {}
                for word in j.split():
                    word = word.strip('.,?!/|\\').lower()
                    if word in paragraph:
                        paragraph[word] += 1
                    else:
                        paragraph[word] = 1
                counted[i['href']] = paragraph
        if not any(counted.values()):
            print 'No associated paragraphs'
        else:
            self.counted = counted
        if console == 'yes':
            return counted
        
    def plt_words(self, numb = 5):
        # Plot frequencies of words, variable numb is how many to plot. 
        # Plots most common words and frequencies minus the common words.
        allwords = {}
        wcount = 0 
        for i,j in self.counted.items():
            for k,l in j.items():
                wcount += l
                if k not in allwords:
                    allwords[k] = l
                else:
                    allwords[k] += l
        
        fig = plt.figure(figsize=(7,7),dpi=600)
        ind = np.arange(numb)
        for x in range(2):
            percents=[]
            if x == 0:
                for i,j in allwords.items():
                    plt.title('Top Words after Exclusion',fontsize=16)
                    figname = 'Top_Real.png'
                    if i not in commons and i not in bad:
                        percents.append((i,float(j)/wcount*100))
            elif x == 1:
                for i,j in allwords.items():
                    if i not in bad:
                        plt.title('Top Words',fontsize=16)
                        figname = 'Top_All.png'
                        percents.append((i,float(j)/wcount*100))
            
            allsorted = sorted(percents,key=lambda x: x[1],reverse=True)
            perc=[]
            name=[]
            for k in range(numb):
                perc.append(allsorted[k][1])
                name.append(allsorted[k][0])

            plt.xlabel('Total Words: '+str(wcount), fontsize=12)
            plt.bar(ind,perc)
            plt.ylabel('Percent', fontsize = 12)
            plt.xticks(ind+0.6/2,name,fontsize = 12, rotation=45)
            plt.savefig(figname, bbox_inches='tight')