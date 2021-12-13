'''
Created on 8 dic 2021

@author: emilio
'''

from entity import *
from validation import lqnsValidator
from validation import matlabValidator
import matplotlib.pyplot as plt
import numpy as np
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    Router = Task(name="Router")
    
    # entries declaration
    Addr1 = Entry("Address1")
    Addr2 = Entry("Address2")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr1)
    Router.addEntry(Addr2)
    
    # activity declaration
    
    # Router  entries logic#
    Addr1.getActivities().append(Activity(stime=1.0, parentEntry=Addr1, name="e"))
    Addr2.getActivities().append(Activity(stime=1.0, parentEntry=Addr2, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr1, parentEntry=browse, name="2Address1"))
    browse.getActivities().append(SynchCall(dest=Addr2, parentEntry=browse, name="2Address2"))
    browse.getActivities().append(Activity(stime=1.0, parentEntry=browse, name="browse"))
    
    # lqn2crn = LQN_CRN()
    # lqn2crn.getCrn({"task":[cTask, Router], "name":"1task2e"})
    #
    # lqn2crn.toMatlab(outDir="../model/validation")
    
    # validate the model against lqns#
    matV = matlabValidator("../model/validation/1task2e/lqn.m")
    lqnV = lqnsValidator("../model/validation/1task2e/lqn_t.lqn")
    
    X0 = [0 for i in range(7)]
    MU = [0 for i in range(7)]
    NC = [0 for i in range(2)]
    NT = [0 for i in range(2)]
    rep = 1
    dt = 10.0 ** -1
    TF = 3000 * dt
    
    T_mat=[]
    Tclient=[]
    e=[]
    
    for i in range(1):
    
        X0[-1] = 104
        MU[2] = 1
        MU[5] = 1
        MU[6] = 1
        NC[1] = 119
        NT[1] = 10
    
        print(X0[-1],NC[1:],NT[1:])
    
        T_mat.append(matV.solveModel(X0, MU, NT, NC,dt))
        T_lqns = lqnV.solveModel(X0=X0[-1], NT=NT, NC=NC)
        for t in T_lqns:
            if(t["task"]=="Client"):
                Tclient.append(t["trg"])
                break
    
        e.append(abs(T_mat[-1]-Tclient[-1])*100/Tclient[-1])
    
    plt.figure()
    plt.stem(Tclient,linefmt="b", markerfmt="bo",label="lqns")
    plt.stem(T_mat,linefmt="g", markerfmt="go",label="matlb")
    plt.legend()
    plt.savefig("1task2e_validation.pdf")
    
    print(e)
    print(Tclient)
    print(T_mat)