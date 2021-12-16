'''
Created on 14 dic 2021

@author: emilio
'''

from .Activity import Activity

class probChoice(Activity):
    
    # probabilita' ramo true di questo brach
    probs = None
    # lista di liste 
    branches = None

    def __init__(self, parent, name, probs=None, branches=None):
        super().__init__(parent=parent, name=name)
        if(branches is None):
            self.branches = []
        if(probs is None):
            self.probs = []
    
    def addBlock(self, blk, p):
        self.probs.append(p)
        self.branches.append(blk)
        blk.parentChoice = self
    
    def getConAct(self):
        return
    
    def getActivities(self):
        return self.branches
    
    def getJoinAct(self):
        idx=self.getParent().getActivities().index(self)
        if(idx==len(self.getParentEntry().getActivities())-1):
            raise ValueError("una prob choice non puo essere ultima istruzione di un blocco")
        return self.getParent().getActivities()[idx+1]
