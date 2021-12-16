'''
Created on 8 dic 2021

@author: emilio
'''


class Entry(object):
    '''
    classdocs
    '''
    
    name = None
    activities = None
    parentTask = None

    def __init__(self, name, activities=None, pTask=None):
        self.name = name
        if(activities is not None):
            self.activities = activities
        else:
            self.activities = []
        self.parentTask = pTask
    
    def setPTask(self, pTask):
        self.pTask = pTask
    
    def getActivities(self):
        return self.activities
    
    def getAct(self,a):
        acts=[]
        for a1 in a.getActivities():
            acts.append(a1)
            acts.extend(self.getAct(a1))
        return acts
        
    def getAllActivities(self):
        acts=[]
        for a in self.getActivities():
            acts.append(a)
            acts.extend(self.getAct(a))
        return acts
            