'''
Created on 8 dic 2021

@author: emilio
'''

from entity import *
from validation import lqnsValidator
from validation import pyValidator
from validation import matlabValidator
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    Router = Task(name="Router")
    Front_end = Task(name="Front_end")
    
    # entries declaration
    Home = Entry("Home")
    Catlog = Entry("Catalog")
    Cart = Entry("Cart")
    Addr = Entry("Address")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr)
    Front_end.addEntry(Home)
    Front_end.addEntry(Catlog)
    Front_end.addEntry(Cart)
    
    # activity declaration
    
    # Router  entries logic#
    Addr.getActivities().append(SynchCall(dest=Home, parentEntry=Addr, name="2Home"))
    Addr.getActivities().append(SynchCall(dest=Catlog, parentEntry=Addr, name="2Catalog"))
    Addr.getActivities().append(SynchCall(dest=Cart, parentEntry=Addr, name="2Cart"))
    Addr.getActivities().append(Activity(stime=1.0, parentEntry=Addr, name="e")) 
    
    # Front_end entries logic#
    Home.getActivities().append(Activity(stime=1.0, parentEntry=Home, name="e"))
    Catlog.getActivities().append(Activity(stime=1.0, parentEntry=Catlog, name="e"))
    Cart.getActivities().append(Activity(stime=1.0, parentEntry=Cart, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr, parentEntry=browse, name="2Address"))
    browse.getActivities().append(Activity(stime=1.0, parentEntry=browse, name="browse"))
    
    lqn2crn = LQN_CRN()
    lqn2crn.getCrn({"task":[cTask, Router, Front_end], "name":"2task3e"})
    
    lqn2crn.toMatlab(outDir="../model/validation/")  
    modelPath=Path("../model/validation/2task3e/lqn.m")
    
    # validate the model against lqns#
    matV = matlabValidator(modelPath)
    #pyV=pyValidator.pyValidator(str(modelDirPath/"lqn.py"))
    lqnV = lqnsValidator("../model/validation/2task3e/lqn_t.lqn")
    
    X0 = [0 for i in range(13)]
    MU = [0 for i in range(13)]
    NC = [0 for i in range(3)]
    NT = [0 for i in range(3)]
    
    T_mat = []
    Tclient = []
    e = []
    
    for i in range(10):
    
        X0[-1] = np.random.randint(low=10, high=300)
        MU[4] = 1 #XHome_e
        MU[7] = 1 #XCatalog_e
        MU[10] = 1 #XCart_e
        MU[11] = 1 #XAddress_e
        MU[12] = 1 #XBrowse_browse
        NC[0] = -1
        NC[1] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
        NC[2] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
        NT[0] = -1
        NT[1] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
        NT[2] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
    
        print(X0[-1], NC[1:], NT[1:])
    
        T_mat.append(matV.solveModel(X0, MU, NT, NC))
        T_lqns = lqnV.solveModel(X0=X0[-1], NT=NT, NC=NC)
        for t in T_lqns:
            if(t["task"] == "Client"):
                Tclient.append(t["trg"])
                break
    
        e.append(abs(T_mat[-1] - Tclient[-1]) * 100 / Tclient[-1])
    
    plt.figure()
    plt.stem(Tclient, linefmt="b", markerfmt="bo", label="lqns")
    plt.stem(T_mat, linefmt="g", markerfmt="go", label="matlb")
    plt.legend()
    plt.savefig("2task3e_validation.pdf")
    
    print(e)
    print(Tclient)
    print(T_mat)
