'''
Created on 8 dic 2021

@author: emilio
'''

from entity.Entry import Entry
from entity.Task import Task
from entity.actBlock import actBlock
from entity.SynchCall import SynchCall
from entity.probChoice import probChoice
from entity.Activity import Activity
from entity.LQN_CRN2 import LQN_CRN2
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
    Home1 = Entry("Home1")
    Home2 = Entry("Home2")
    Addr = Entry("Address")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr)
    Front_end.addEntry(Home1)
    Front_end.addEntry(Home2)
    
    # activity declaration
    
    # Router  entries logic#
    choiceAddress=probChoice(parent=Addr, name="Choice")
    tBlk=actBlock(parent=choiceAddress, name="tBlk")
    tBlk.activities.append(SynchCall(dest=Home1, parent=tBlk, name="2Home1"))
    fBlk=actBlock( parent=choiceAddress, name="fBlk")
    fBlk.activities.append(SynchCall(dest=Home2, parent=fBlk, name="2Home2"))
    
    choiceAddress.addBlock(tBlk, 0.5)
    choiceAddress.addBlock(fBlk, 0.5)
    
    Addr.getActivities().append(choiceAddress)
    Addr.getActivities().append(Activity(stime=1.0, parent=Addr, name="e"))
    
    # front_end entries logic#
    Home1.getActivities().append(Activity(stime=1.0, parent=Home1, name="e"))
    Home2.getActivities().append(Activity(stime=1.0, parent=Home2, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr, parent=browse, name="2Address"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask, Router,Front_end], "name":"2task_prob"})
    
    
    lqn2crn.toMatlab(outDir="../model/validation")
    
    # # validate the model against lqns#
    # matV = matlabValidator("../model/validation/2task/lqn.m")
    # lqnV = lqnsValidator("../model/validation/2task/lqn_t.lqn")
    #
    # X0 = [0 for i in range(7)]
    # MU = [0 for i in range(7)]
    # NC = [0 for i in range(7)]
    # NT = [0 for i in range(7)]
    # rep = 1
    # dt = 10.0 ** -1
    # TF = 3000 * dt
    #
    # T_mat=[]
    # Tclient=[]
    # e=[]
    #
    # for i in range(15):
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