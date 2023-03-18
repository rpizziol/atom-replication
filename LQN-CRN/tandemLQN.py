'''
Created on 8 dic 2021

@author: emilio
'''

from entity import *
# from validation import lqnsValidator
# from validation import pyValidator
# from validation import matlabValidator
# import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
        
if __name__ == '__main__':
    
    # task declaration
    C = Task(name="C", ref=True)
    T = Task(name="T")
    
    # entries declaration
    b = Entry("B")
    e = Entry("E1")
    
    C.addEntry(b)
    T.addEntry(e)
    
    
    b.getActivities().append(SynchCall(dest=e, parent=b, name="2E1"))
    b.getActivities().append(Activity(stime=1.0, parent=b, name="e")) 
        
    e.getActivities().append(Activity(stime=1.0, parent=e, name="E1_c1"))
    e.getActivities().append(Activity(stime=1.0, parent=e, name="e"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[C,T], "name":"tandemLQN"})
    
    lqn2crn.toMatlab(outDir="../model/validation/")  
    modelPath=Path("../model/validation/tandemLQN/lqn.m")
    
    # # validate the model against lqns#
    # matV = matlabValidator(modelPath)
    # #pyV=pyValidator.pyValidator(str(modelDirPath/"lqn.py"))
    # lqnV = lqnsValidator("../model/validation/2task3e/lqn_t.lqn")
    #
    # X0 = [0 for i in range(13)]
    # MU = [0 for i in range(13)]
    # NC = [0 for i in range(3)]
    # NT = [0 for i in range(3)]
    #
    # T_mat = []
    # Tclient = []
    # e = []
    #
    # for i in range(5):
    #
    #     X0[-1] = np.random.randint(low=10, high=300)
    #     MU[4] = 1 #XHome_e
    #     MU[7] = 1 #XCatalog_e
    #     MU[10] = 1 #XCart_e
    #     MU[11] = 1 #XAddress_e
    #     MU[12] = 1 #XBrowse_browse
    #     NC[0] = -1
    #     NC[1] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
    #     NC[2] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
    #     NT[0] = -1
    #     NT[1] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
    #     NT[2] = np.random.randint(low=int(X0[-1] / 3), high=X0[-1] * 3)
    #
    #     print(X0[-1], NC[1:], NT[1:])
    #
    #     T_mat.append(matV.solveModel(X0, MU, NT, NC))
    #     T_lqns = lqnV.solveModel(X0=X0[-1], NT=NT, NC=NC)
    #     for t in T_lqns:
    #         if(t["task"] == "Client"):
    #             Tclient.append(t["trg"])
    #             break
    #
    #     e.append(abs(T_mat[-1] - Tclient[-1]) * 100 / Tclient[-1])
    #
    # plt.figure()
    # plt.stem(Tclient, linefmt="b", markerfmt="bo", label="lqns")
    # plt.stem(T_mat, linefmt="g", markerfmt="go", label="matlb")
    # plt.legend()
    # plt.savefig("2task3e_validation.pdf")
    #
    # print(e)
    # print(Tclient)
    # print(T_mat)
