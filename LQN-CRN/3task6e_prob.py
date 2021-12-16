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
    Home = Entry("Home")
    Catalog= Entry("Catalog")
    Cart= Entry("Cart")
    Addr = Entry("Address")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr)
    Front_end.addEntry(Home)
    Front_end.addEntry(Catalog)
    Front_end.addEntry(Cart)
    
    # activity declaration
    
    # Router  entries logic#
    choiceAddress=probChoice(parent=Addr, name="Choice")
    AddrBlk1=actBlock(parent=choiceAddress, name="AddrBlk1")
    AddrBlk1.activities.append(SynchCall(dest=Home, parent=AddrBlk1, name="2Home"))
    AddrBlk2=actBlock( parent=choiceAddress, name="AddrBlk2")
    AddrBlk2.activities.append(SynchCall(dest=Catalog, parent=AddrBlk2, name="2Catalog"))
    AddrBlk3=actBlock( parent=choiceAddress, name="AddrBlk3")
    AddrBlk3.activities.append(SynchCall(dest=Cart, parent=AddrBlk3, name="2Cart"))
    
    choiceAddress.addBlock(AddrBlk1, 1.0/3)
    choiceAddress.addBlock(AddrBlk2, 1.0/3)
    choiceAddress.addBlock(AddrBlk3, 1.0/3)
    
    Addr.getActivities().append(choiceAddress)
    Addr.getActivities().append(Activity(stime=1.0, parent=Addr, name="e"))
    
    # front_end entries logic#
    Home.getActivities().append(Activity(stime=1.0, parent=Home, name="e"))
    Catalog.getActivities().append(Activity(stime=1.0, parent=Catalog, name="e"))
    Cart.getActivities().append(Activity(stime=1.0, parent=Cart, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr, parent=browse, name="2Address"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask, Router,Front_end], "name":"3task6e_prob"})
    
    
    lqn2crn.toMatlab(outDir="../model/validation")
    
    # validate the model against lqns#
    matV = matlabValidator("../model/validation/3task6e_prob/lqn.m")
    lqnV = lqnsValidator("../model/validation/3task6e_prob/lqn_t.lqn")
    
    X0 = [0 for i in range(17)]
    MU = [0 for i in range(17)]
    NC = [0 for i in range(3)]
    NT = [0 for i in range(3)]
    rep = 1
    dt = 10.0 ** -1
    TF = 3000 * dt
    
    T_mat=[]
    Tclient=[]
    e=[]
    
    for i in range(1):
    
        X0[-1] = np.random.randint(low=10,high=300)
        
        
        MU[6] = 1.0/4.4420  #Home
        MU[10] = 1.0/1.1105 #Catalog
        MU[14] = 1.0/9.6215 #Cart
        MU[15] = 1.0/1.2436 #Addres
        MU[16] = 1.0/1.1325 #Browse
        
        NC[0] = -1
        NC[1] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
        NC[2] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
        NT[0] = -1
        NT[1] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
        NT[2] = np.random.randint(low=int(X0[-1]/2),high=X0[-1]*2)
    
        print(X0[-1],NC[1:],NT[1:])
    
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
    plt.savefig("3task6e_prob-validation.pdf")
    
    print(e)
    print(Tclient)
    print(T_mat)