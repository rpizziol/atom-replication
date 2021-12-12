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
    t1 = Task(name="t1")
    
    # entries declaration
    e1 = Entry("e1")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    t1.addEntry(e1)
    
    # activity declaration
    
    # t1 entries logic#
    e1.getActivities().append(Activity(stime=1.0, parentEntry=e1, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=e1, parentEntry=browse, name="2e1"))
    browse.getActivities().append(Activity(stime=1.0, parentEntry=browse, name="browse"))
    
    lqn2crn = LQN_CRN()
    lqn2crn.getCrn({"task":[cTask, t1], "name":"single_task"})
    
    lqn2crn.toMatlab(outDir="../model/validation")
    
    # validate the model against lqns#
    matV = matlabValidator("../model/validation/single_task/lqn.m")
    lqnV = lqnsValidator("../model/validation/single_task/lqn_t.lqn")
    
    X0 = [0 for i in range(4)]
    MU = [0 for i in range(4)]
    NC = [0 for i in range(2)]
    NT = [0 for i in range(2)]
    rep = 1
    dt = 10.0 ** -1
    TF = 3000 * dt
    
    T_mat=[]
    Tclient=[]
    e=[]
    
    for i in range(15):
    
        X0[3] = np.random.randint(low=1,high=200)
        MU[2] = 1
        MU[3] = 1
        NC[0] = -1
        NC[1] = np.random.randint(low=int(X0[3]/2),high=X0[3]*2)
        NT[0] = -1
        NT[1] = np.random.randint(low=int(X0[3]/2),high=X0[3]*2)
        
        print(X0[3],NC[1],NT[1])
        
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
    plt.show()
    
    print(e)