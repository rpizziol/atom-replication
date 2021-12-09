'''
Created on 8 dic 2021

@author: emilio
'''

import numpy as np
from entity import Activity
from entity import Entry
from entity import SynchCall
from entity import Task
from entity import LQN_CRN


        
if __name__ == '__main__':
    
    #task declaration
    cTask = Task(name="Client", tsize=1, entries=None, processor=None,ref=True)
    routerTask = Task(name="Router", tsize=1, entries=None, processor=None)
    feTask = Task(name="Front_end", tsize=1, entries=None, processor=None)
    
    #entries declaration
    addr = Entry("Address")
    home_fe = Entry("Home")
    cat_fe = Entry("Catalog")
    crts_fe = Entry("Carts")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    routerTask.addEntry(addr)
    feTask.addEntry(home_fe)
    feTask.addEntry(cat_fe)
    feTask.addEntry(crts_fe)
    
    
    #activity declaration
    
    #router entries logic#
    addr.getActivities().append(SynchCall(dest=home_fe,parentEntry=addr,name="2Home"))
    addr.getActivities().append(SynchCall(dest=cat_fe,parentEntry=addr,name="2Catalog"))
    addr.getActivities().append(SynchCall(dest=crts_fe,parentEntry=addr,name="2Carts"))
    addr.getActivities().append(Activity(stime=1.0,parentEntry=addr,name="e"))
    
    #front end entries logic#
    home_fe.getActivities().append(Activity(stime=1.0,parentEntry=home_fe,name="e"))
    cat_fe.getActivities().append(Activity(stime=1.0,parentEntry=cat_fe,name="e"))
    crts_fe.getActivities().append(Activity(stime=1.0,parentEntry=crts_fe,name="e"))
    
    #client logic#
    browse.getActivities().append(SynchCall(dest=addr,parentEntry=browse,name="2Address"))
    browse.getActivities().append(Activity(stime=1.0,parentEntry=browse,name="browse"))
    
    
    lqn2crn=LQN_CRN()
    lqn2crn.getCrn({"task":[cTask,routerTask,feTask]})
    
    print(lqn2crn.names)
    print(np.matrix(lqn2crn.Jumps))