'''
Created on 8 dic 2021

@author: emilio
'''

from entity import *  
import matplotlib.pyplot as plt
import numpy as np
import scipy.io as sp
from pathlib import Path
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    T1 = Task(name="T1")
    T2 = Task(name="T2")
    T3 = Task(name="T3")
    
    # entries declaration
    browse = Entry("browse")
    e1 = Entry("e1")
    e2 = Entry("e2")
    e3 = Entry("e3")
    
    cTask.addEntry(browse)
    T1.addEntry(e1)
    T2.addEntry(e2)
    T3.addEntry(e3)
    
    # activity declaration
    e3.getActivities().append(Activity(stime=1.0, parent=e3, name="e"))
    
    e2.getActivities().append(SynchCall(dest=e3, parent=e2, name="2e3"))
    e2.getActivities().append(Activity(stime=1.0, parent=e2, name="e"))
    
    e1.getActivities().append(SynchCall(dest=e2, parent=e1, name="2e2"))
    e1.getActivities().append(Activity(stime=1.0, parent=e1, name="e"))
    
    browse.getActivities().append(SynchCall(dest=e1, parent=browse, name="2e1"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    mname="_3tierGPS"
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask, T1,T2,T3], "name":mname})
    
    #lqn2crn.toCasadiCtrl(outDir="./controller")
    lqn2crn.toMatlab(outDir="../model/validation")
    #lqn2crn.toJuliaCtrl(outDir="./controller/julia")
    
    # # validate the model against lqns#
    # matV = matlabValidator("../model/validation/%s/lqn.m"%(mname))
    # lqnV = lqnsValidator("../model/validation/%s/lqn_t.lqn"%(mname))
    #
    # X0 = [0 for i in range(7)]
    # MU = [0 for i in range(7)]
    # NC = [0 for i in range(3)]
    # NT = [0 for i in range(3)]
    # names = [None] * 7
    #
    # Tclient = []
    # e = []
    # mat_v=[]
    # lqsim_v=[]
    #
    # for i in range(1):
    #
    #
    #
    #     X0[-1] = np.random.randint(low=50,high=300)
    #
    #     MU[4] = 1.
    #     names[4] = "Home"
    #     MU[5] = 1.
    #     names[5] = "Address"
    #     MU[6] = 1.
    #     names[6] = "Browse"
    #     NC[0] = -1
    #     NC[1] = np.random.randint(low=1,high=X0[-1]*2)
    #     NC[2] = np.random.randint(low=1,high=X0[-1]*2)
    #     NT[0] = -1
    #     NT[1] = np.random.randint(low=1,high=X0[-1]*2)
    #     NT[2] = np.random.randint(low=1,high=X0[-1]*2)
    #
    #     print(X0[-1],NC[1:],NT[1:])
    #
    #     T_mat=matV.solveModel(X0, MU, NT,NC,dt=0.1,Names=names)
    #     T_lqns = lqnV.solveModel(X0=X0[-1], NT=NT, NC=NC,Names=names)
    #     for ent in names:
    #         if(ent is not None):
    #             print(ent,T_lqns[ent],T_mat[ent])
    #             e.append(abs(T_lqns[ent]-T_mat[ent]) * 100 /T_lqns[ent])
    #
    #     mat_v.append(T_mat)
    #     lqsim_v.append(T_lqns) 
    #
    # Path("vdata/%s/"%(mname)).mkdir( parents=True, exist_ok=True )
    # sp.savemat("vdata/%s/res.mat"%(mname),{"mat":mat_v,"lqsim":lqsim_v})
    #
    # plt.figure()
    # plt.boxplot(e)
    # plt.ylabel("Relative Error(%)")
    # plt.savefig("%s-validation.pdf"%(mname))
    #
    # print(e)