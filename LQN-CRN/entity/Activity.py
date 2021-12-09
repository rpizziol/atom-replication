'''
Created on 8 dic 2021

@author: emilio
'''

class Activity(object):
    
    succ=None
    stime=None
    parentEntry=None
    visited=False
    name=None

    def __init__(self,stime=None,parentEntry=None,name=None):
        self.stime=stime
        self.parentEntry=parentEntry
        self.succ=None
        self.name=name
    
    def addNext(self,succ):
        self.succ=succ
    
    def getNext(self):
        return self.succ
    
    def getConAct(self):
        return []
    
    def setPEntry(self,parentEntry):
        self.parentEntry=parentEntry
        
    def isVisited(self):
        return self.visited