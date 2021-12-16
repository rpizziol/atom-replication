'''
Created on 14 dic 2021

@author: emilio
'''

from .Activity import Activity

class actBlock(Activity):

    activities = None
    
    def __init__(self, parent, name):
        super().__init__(parent=parent, name=name)
        self.activities = []
    
    def getActivities(self):
        return self.activities
