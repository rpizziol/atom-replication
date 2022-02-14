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
    A = Task(name="A")
    B = Task(name="B")
    
    
    # entries declaration
    e1 = Entry("e1")
    e2 = Entry("e2")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    A.addEntry(e1)
    B.addEntry(e2)
    
    # Router  entries logic#
    e1.getActivities().append(Activity(stime=1.0, parent=e1, name="e"))
    e2.getActivities().append(Activity(stime=1.0, parent=e2, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=e1, parent=browse, name="2e1"))
    browse.getActivities().append(SynchCall(dest=e2, parent=browse, name="2e2"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask, A,B], "name":"lqn2qn"})
    
    lqn2crn.toMatlab(outDir="../model/validation")
    
    # # validate the model against lqns#
    # matV = matlabValidator("../model/validation/1task2e/lqn.m")
    # lqnV = lqnsValidator("../model/validation/1task2e/lqn_t.lqn")
    #
    # X0 = [0 for i in range(7)]
    # MU = [0 for i in range(7)]
    # NC = [0 for i in range(2)]
    # NT = [0 for i in range(2)]
    # rep = 1
    # dt = 10.0 ** -1
    # TF = 3000 * dt
    #
    # T_mat=[]
    # Tclient=[]
    # e=[]
    #
    # for i in range(5):
    #
    #     X0[-1] = np.random.randint(low=10,high=300)
    #     MU[2] = 1
    #     MU[5] = 1
    #     MU[6] = 1
    #     NC[1] = np.random.randint(low=10,high=300)
    #     NT[1] = np.random.randint(low=10,high=300)
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
    # plt.savefig("1task2e_validation.pdf")
    #
    # print(e)
    # print(Tclient)
    # print(T_mat)