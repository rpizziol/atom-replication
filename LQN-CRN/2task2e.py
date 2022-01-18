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
    TCristo = Task(name="TCristo")
    T1 = Task(name="T1")
    T2 = Task(name="T2")
    T3 = Task(name="T3")
    
    # entries declaration
    browse = Entry("Browse")
    ECristo=Entry("ECristo")
    E1 = Entry("E1")
    E2 = Entry("E2")
    E3 = Entry("E3")
    
    cTask.addEntry(browse)
    TCristo.addEntry(ECristo)
    T1.addEntry(E1)
    T2.addEntry(E2)
    T3.addEntry(E3)
    
    # activity declaration
    
    # Front_end  entries logic#
    E3.getActivities().append(Activity(stime=1.0, parent=E3, name="e"))
    
    E2.getActivities().append(SynchCall(dest=E3, parent=E2, name="E2ToE3"))
    E2.getActivities().append(Activity(stime=1.0, parent=E2, name="e"))
    
    E1.getActivities().append(SynchCall(dest=E3, parent=E1, name="E1ToE3"))
    E1.getActivities().append(Activity(stime=1.0, parent=E1, name="e"))
    
    
    choiceCristo=probChoice(parent=ECristo, name="Choice")

    blkE1=actBlock(parent=choiceCristo, name="BlkE1")
    blkE1.activities.append(SynchCall(dest=E1, parent=blkE1, name="2E1"))
    
    blkE2=actBlock(parent=choiceCristo, name="BlkE2")
    blkE2.activities.append(SynchCall(dest=E2, parent=blkE2, name="2E2"))
    
    choiceCristo.addBlock(blkE1,1.0/2)
    choiceCristo.addBlock(blkE2,1.0/2)
    
    ECristo.getActivities().append(choiceCristo)
    ECristo.getActivities().append(Activity(stime=1.0, parent=ECristo, name="e"))
    
    
    # client logic#
    
    browse.getActivities().append(SynchCall(dest=ECristo, parent=browse, name="2ECristo"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask,TCristo,T1,T2,T3], "name":"2task2e"})
    
    lqn2crn.toMatlab(outDir="../model/validation")
    lqn2crn.toJuliaCtrl(outDir="./controller/julia")
    
    # validate the model against lqns#
    # matV = matlabValidator("../model/validation/2task2e/lqn.m")
    # lqnV = lqnsValidator("../model/validation/2task2e/lqn_t.lqn")
    
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