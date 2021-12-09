'''
Created on 8 dic 2021

@author: emilio
'''

from .Call import Call

class SynchCall(Call):
    '''
    classdocs
    '''

    def __init__(self, dest,parentEntry=None,name=None):
        super().__init__(dest,parentEntry,name=name)
    
    def getConAct(self):
        return self.dest.getActivities()