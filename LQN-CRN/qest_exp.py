from entity import *
import matplotlib.pyplot as plt
import numpy as np
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="C", ref=True)
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
    
    #E2logic#
    E2.getActivities().append(Activity(stime=1.0, parent=E2, name="e"))
    
    #E1logic#
    choiceE1=probChoice(parent=E1, name="ChoiceE1")
    
    BlkSynch=actBlock(parent=choiceE1, name="BlkSynch")
    BlkSynch.activities.append(SynchCall(dest=E2, parent=BlkSynch, name="2E2Synch"))
    BlkSynch.activities.append(Activity(stime=1.0, parent=BlkSynch, name="2E2Synch_e"))
    
    BlkAsynch=actBlock(parent=choiceE1, name="BlkAsynch")
    BlkAsynch.activities.append(SynchCall(dest=E2, parent=BlkAsynch, name="2E2Asynch"))
    BlkAsynch.activities.append(Activity(stime=1.0, parent=BlkAsynch, name="2E2Asynch_e"))
    
    choiceE1.addBlock(BlkSynch, "P_synch")
    choiceE1.addBlock(BlkAsynch, "P_asynch")
    
    E1.getActivities().append(choiceE1)
    E1.getActivities().append(Activity(stime=1.0, parent=E1, name="e"))
    
    
    #Blogic#
    browse.getActivities().append(SynchCall(dest=E1, parent=browse, name="2E1"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    LQN={"task":[cTask,T1,T2], "name":"QestLqn"}
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn(LQN)
    
    lqn2crn.toMatlab(outDir="../model/validation")