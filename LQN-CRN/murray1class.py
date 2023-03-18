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
    usersTask = Task(name="Users", ref=True)
    appTask = Task(name="App")
    httpServerTask = Task(name="HTTPServer")
    db1Task = Task(name="DB1")
    db2Task = Task(name="DB2")
    
    # entries declaration
    userWork = Entry("userWork")
    appRequest = Entry("appRequest")
    accept = Entry("accept")
    dbAccess1 = Entry("dbAccess1")
    dbAccess2 = Entry("dbAccess2")
    
    usersTask.addEntry(userWork)
    appTask.addEntry(appRequest)
    httpServerTask.addEntry(accept)
    db1Task.addEntry(dbAccess1)
    db2Task.addEntry(dbAccess2)
    
    
    userWork.getActivities().append(SynchCall(dest=accept, parent=userWork, name="2Accept"))
    userWork.getActivities().append(Activity(stime=1.0, parent=userWork, name="e")) 
    
    accept.getActivities().append(SynchCall(dest=appRequest, parent=accept, name="2AppRequest"))
    accept.getActivities().append(SynchCall(dest=dbAccess2, parent=accept, name="2dbAccess"))
    accept.getActivities().append(Activity(stime=1.0, parent=accept, name="e"))
    
    appRequest.getActivities().append(SynchCall(dest=dbAccess1, parent=appRequest, name="2dbAccess2"))
    appRequest.getActivities().append(Activity(stime=1.0, parent=appRequest, name="e"))
    
    dbAccess1.getActivities().append(Activity(stime=1.0, parent=dbAccess1, name="e"))
    dbAccess2.getActivities().append(Activity(stime=1.0, parent=dbAccess2, name="e"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[usersTask,appTask,httpServerTask,db1Task,db2Task], "name":"murray1class_3"})
    
    lqn2crn.toMatlab(outDir="../model/validation/")  
    modelPath=Path("../model/validation/murray1class_3/lqn.m")
    
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
