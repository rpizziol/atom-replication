'''
Created on 8 dic 2021

@author: emilio
'''

from .Call import Call

class AsynchCall(Call):
    '''
    classdocs
    '''

    def __init__(self, dest,parent=None,name=None):
        super().__init__(dest,parent,name=name)
    
    def getConAct(self):
        return self.dest.getActivities()