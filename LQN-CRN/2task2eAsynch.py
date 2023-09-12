'''
Created on 8 dic 2021

@author: emilio
'''

from entity import *
#from validation import lqnsValidator
#from validation import matlabValidator
import matplotlib.pyplot as plt
import numpy as np
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    T1 = Task(name="T1")
    T2 = Task(name="T2")
    
    # entries declaration
    browse = Entry("Browse")
    E1 = Entry("E1")
    E2 = Entry("E2")
    
    cTask.addEntry(browse)
    T1.addEntry(E1)
    T2.addEntry(E2)
    
    # activity declaration
    
    # Front_end  entries logic#
    E2.getActivities().append(Activity(stime=1.0, parent=E2, name="e"))
    
    E1.getActivities().append(AsynchCall(dest=E2, parent=E1, name="E1ToE2"))
    E1.getActivities().append(Activity(stime=1.0, parent=E1, name="e"))
    
    
    
    # client logic#
    
    browse.getActivities().append(SynchCall(dest=E1, parent=browse, name="2E1"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask,T1,T2], "name":"2task2eAsynch"})
    
    lqn2crn.toMatlab(outDir="../model/validation")
    #lqn2crn.toJuliaCtrl(outDir="./controller/julia")