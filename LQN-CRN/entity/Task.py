'''
Created on 8 dic 2021

@author: emilio
'''


class Task(object):
    '''
    classdocs
    '''
    
    name = None
    tsize = None
    entries = None
    processor = None
    ref=None

    def __init__(self, name=None, tsize=None, entries=None, processor=None,ref=False):
        self.name = name
        self.tsize = tsize
        if(entries==None):
            self.entries = []
        else:
            self.entries = entries
        self.processor = processor
        self.ref=ref

    def addEntry(self,entry):
        entry.parentTask=self
        self.entries.append(entry)
    
    def getEntries(self):
        return self.entries