'''
Created on 8 dic 2021

@author: emilio
'''

from entity import *
from validation import lqnsValidator
from validation import matlabValidator
import matplotlib.pyplot as plt
import numpy as np
import scipy.io as sp
from pathlib import Path
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    Router = Task(name="Router")
    Front_end = Task(name="Front_end")
    
    # entries declaration
    Home = Entry("Home")
    Addr = Entry("Address")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr)
    Front_end.addEntry(Home)
    
    # activity declaration
    
    # Front_end  entries logic#
    Addr.getActivities().append(SynchCall(dest=Home, parent=Addr, name="2Home"))
    Addr.getActivities().append(Activity(stime=1.0, parent=Addr, name="e"))
    
    # Router entries logic#
    Home.getActivities().append(Activity(stime=1.0, parent=Home, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr, parent=browse, name="2Address"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    mname="_2tier"
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask, Router,Front_end], "name":mname})
    
    lqn2crn.toCasadiCtrl(outDir="./controller")
    lqn2crn.toMatlab(outDir="../model/validation")
    lqn2crn.toJuliaCtrl(outDir="./controller/julia")
    
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