'''
Created on 8 dic 2021

@author: emilio
'''

from .Activity import Activity

class Call(Activity):
    
    dest=None

    def __init__(self, dest,parentEntry=None,name=None):
        super().__init__(dest,parentEntry=parentEntry,name=name)
        self.dest=dest
    
    def getConAct(self):
        raise NotImplementedError 