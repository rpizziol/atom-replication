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
    Front_end = Task(name="Front_end")
    
    # entries declaration
    Catalog = Entry("Catalog")
    Home = Entry("Home")
    Addr_h = Entry("AddressH")
    Addr_c = Entry("AddressC")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr_h)
    Router.addEntry(Addr_c)
    Front_end.addEntry(Home)
    Front_end.addEntry(Catalog)
    
    # activity declaration
    
    # Front_end  entries logic#
    Addr_h.getActivities().append(SynchCall(dest=Home, parentEntry=Addr_h, name="2Home"))
    Addr_h.getActivities().append(Activity(stime=1.0, parentEntry=Addr_h, name="e"))
    Addr_c.getActivities().append(SynchCall(dest=Catalog, parentEntry=Addr_c, name="2Catalog"))
    Addr_c.getActivities().append(Activity(stime=1.0, parentEntry=Addr_c, name="e"))
    
    # Router entries logic#
    Home.getActivities().append(Activity(stime=1.0, parentEntry=Home, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr_h, parentEntry=browse, name="2Addressh"))
    browse.getActivities().append(Activity(stime=1.0, parentEntry=browse, name="browse1"))
    browse.getActivities().append(SynchCall(dest=Addr_c, parentEntry=browse, name="2Addressc"))
    browse.getActivities().append(Activity(stime=1.0, parentEntry=browse, name="browse"))
    
    lqn2crn = LQN_CRN()
    lqn2crn.getCrn({"task":[cTask, Router,Front_end], "name":"2task2e"})
    
    lqn2crn.toMatlab(outDir="../model/validation")
    
    # validate the model against lqns#
    matV = matlabValidator("../model/validation/2task2e/lqn.m")
    lqnV = lqnsValidator("../model/validation/2task2e/lqn_t.lqn")
    
    X0 = [0 for i in range(7)]
    MU = [0 for i in range(7)]
    NC = [0 for i in range(7)]
    NT = [0 for i in range(7)]
    rep = 1
    dt = 10.0 ** -1
    TF = 3000 * dt
    
    T_mat=[]
    Tclient=[]
    e=[]
    
    # for i in range(1):
    #
    #     X0[-1] = np.random.randint(low=10,high=300)
    #     MU[4] = 1
    #     MU[5] = 1
    #     MU[6] = 1
    #     NC[0] = -1
    #     NC[1] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
    #     NC[2] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
    #     NT[0] = -1
    #     NT[1] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
    #     NT[2] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
    #
    #     print(X0[-1],NC[1:],NT[1:])
    #
    #     T_mat.append(matV.solveModel(X0, MU, NT, NC,dt))
    #     T_lqns = lqnV.solveModel(X0=X0[-1], NT=NT, NC=NC)
    #     for t in T_lqns:
    #         if(t["task"]=="Client"):
    #             Tclient.append(t["trg"])
    #             break
    #
    #     e.append(abs(T_mat[-1]-Tclient[-1])*100/Tclient[-1])
    #
    # plt.figure()
    # plt.stem(Tclient,linefmt="b", markerfmt="bo",label="lqns")
    # plt.stem(T_mat,linefmt="g", markerfmt="go",label="matlb")
    # plt.legend()
    # plt.savefig("2task_validation.pdf")
    #
    # print(e)
    # print(Tclient)
    # print(T_mat)