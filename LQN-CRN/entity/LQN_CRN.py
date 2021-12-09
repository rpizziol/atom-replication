'''
Created on 9 dic 2021

@author: emilio
'''

import traceback
from entity.Call import Call


class LQN_CRN():
    
    Jumps = None
    prop = None
    names = None
    lqn = None
    isStateMapped = None
    
    def __init__(self):
        self.Jumps = []
        self.prop = []
        self.names = []
        self.isStateMapped=False
    
    def visit(self, act):
        # print("activity:"+act.name, "Entry:"+act.parentEntry.name, "Task:"+act.parentEntry.parentTask.name)
        
        idx = act.parentEntry.getActivities().index(act)
        sndName = None  # id dello stato locale da cui sottrarre
        lrcvName = None  # id dello stato da locale a cui aggiungere 
        rrcvName = None  # id dello stato remoto a cui aggiungere
        
        if(not self.isStateMapped):
            #la prima volta sviluppo lo stato
            if(act.parentEntry.getActivities().index(act) == 0 and not act.parentEntry.parentTask.ref):
                self.names.append("X%s_a" % (act.parentEntry.name))
            self.names.append("X%s_%s" % (act.parentEntry.name, act.name))
        
        else:
            jump=[0]*len(self.names)
            #la seconda sviluppo i jump
            if(not act.parentEntry.parentTask.ref):
                if(idx == 0):
                    sndName = "X%s_a" % (act.parentEntry.name)
                    lrcvName = "X%s_%s" % (act.parentEntry.name, act.name)
                else:
                    sndName = "X%s_%s" % (act.parentEntry.name, act.parentEntry.getActivities()[idx - 1].name)
                    lrcvName = "X%s_%s" % (act.parentEntry.name, act.name)
                
                if(isinstance(act, Call)):
                    rrcvName = "X%s_a" % (act.dest.name)
            else:
                sndName = "X%s_%s" % (act.parentEntry.name, act.parentEntry.getActivities()[idx - 1].name)
                lrcvName = "X%s_%s" % (act.parentEntry.name, act.name)
                
                if(isinstance(act, Call)):
                    rrcvName = "X%s_a" % (act.dest.name)
            
            
            jump[self.names.index(sndName)]=-1
            jump[self.names.index(lrcvName)]=1
            if(rrcvName is not None): 
                jump[self.names.index(rrcvName)]=1
            
            self.Jumps.append(jump)
            #print(sndName, lrcvName, rrcvName)
            
        for a in act.getConAct():
            self.visit(a)   
    
    def getCrn(self, lqn):
        self.lqn = lqn
        try:
            # assumo che il primo task sia il reference task
            ref = self.lqn["task"][0].getEntries()[0]
            for a in ref.getActivities():
                self.visit(a)
                
            self.isStateMapped=True
            
            # assumo che il primo task sia il reference task
            ref = self.lqn["task"][0].getEntries()[0]
            for a in ref.getActivities():
                self.visit(a)
            
        except:
            traceback.print_exc()
        
