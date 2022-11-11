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
    ms = Task(name="MS")
    
    # entries declaration
    search = Entry("Search")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    ms.addEntry(search)
    
    # activity declaration
    
    # Search  entries logic#
    choiceSearch=probChoice(parent=search, name="Choice")
    BlkC1=actBlock(parent=choiceSearch, name="BlkC1")
    BlkC1.activities.append(Activity(stime=1.0, parent=BlkC1, name="c1_e"))
    BlkC2=actBlock(parent=choiceSearch, name="BlkC2")
    BlkC2.activities.append(Activity(stime=1.0, parent=BlkC2, name="c2_e"))
    
    choiceSearch.addBlock(BlkC1, "P_c1")
    choiceSearch.addBlock(BlkC2, "P_c2")
    
    search.getActivities().append(choiceSearch)
    search.getActivities().append(Activity(stime=1.0, parent=search, name="e"))
    
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=search, parent=browse, name="2Search"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask,ms], "name":"runExp"})
    
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