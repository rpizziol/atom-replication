'''
Created on 8 dic 2021

@author: emilio
'''

class Entry(object):
    '''
    classdocs
    '''
    
    name=None
    activities=None
    parentTask=None

    def __init__(self,name,activities=None,pTask=None):
        self.name=name
        if(activities is not None):
            self.activities=activities
        else:
            self.activities=[]
        self.parentTask=pTask
    
    def setPTask(self,pTask):
        self.pTask=pTask
    
    def getActivities(self):
        return self.activities