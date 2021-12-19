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
import scipy.io as sp
from pathlib import Path
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    Router = Task(name="Router")
    Front_end = Task(name="Front_end")
    CatalogSvc = Task(name="CatalogSvc")
    CatalogDB = Task(name="CatalogStorage")
    CartSvc = Task(name="CartSvc")
    CartDB = Task(name="CartStorage")
    
    # entries declaration
    
    CartQuery = Entry("CartQuery")
    Get = Entry("Get")
    Add = Entry("Add")
    Delete = Entry("Remove")
    CatQuery = Entry("CatQuery")
    List = Entry("List")
    Item = Entry("Item")
    Home = Entry("Home")
    Catalog = Entry("Catalog")
    Cart = Entry("Cart")
    Addr = Entry("Address")
    browse = Entry("Browse")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr)
    Front_end.addEntry(Home)
    Front_end.addEntry(Catalog)
    Front_end.addEntry(Cart)
    CatalogSvc.addEntry(List)
    CatalogSvc.addEntry(Item)
    CatalogDB.addEntry(CatQuery)
    CartSvc.addEntry(Get)
    CartSvc.addEntry(Add)
    CartSvc.addEntry(Delete)
    CartDB.addEntry(CartQuery)
    
    # activity declaration
    CartQuery.getActivities().append(Activity(stime=1.0, parent=CartQuery, name="e"))
    
    # CartSvcLogic
    Get.getActivities().append(SynchCall(dest=CartQuery, parent=Get, name="2CartQryGet"))
    Get.getActivities().append(Activity(stime=1.0, parent=Get, name="e"))
    Add.getActivities().append(SynchCall(dest=CartQuery, parent=Add, name="2CartQryAdd"))
    Add.getActivities().append(Activity(stime=1.0, parent=Add, name="e"))
    Delete.getActivities().append(SynchCall(dest=CartQuery, parent=Delete, name="2CartQryRmv"))
    Delete.getActivities().append(Activity(stime=1.0, parent=Delete, name="e"))
    
    # CatalogDBLogic
    CatQuery.getActivities().append(Activity(stime=1.0, parent=CatQuery, name="e"))
    
    # CatalogSvcLogic
    List.getActivities().append(SynchCall(dest=CatQuery, parent=List, name="2QueryLst"))
    List.getActivities().append(Activity(stime=1.0, parent=List, name="e"))
    Item.getActivities().append(SynchCall(dest=CatQuery, parent=Item, name="2QueryItm"))
    Item.getActivities().append(Activity(stime=1.0, parent=Item, name="e"))
    
    # Router  entries logic#
    choiceAddress = probChoice(parent=Addr, name="Choice")
    AddrBlk1 = actBlock(parent=choiceAddress, name="AddrBlk1")
    AddrBlk1.activities.append(SynchCall(dest=Home, parent=AddrBlk1, name="2Home"))
    AddrBlk2 = actBlock(parent=choiceAddress, name="AddrBlk2")
    AddrBlk2.activities.append(SynchCall(dest=Catalog, parent=AddrBlk2, name="2Catalog"))
    AddrBlk3 = actBlock(parent=choiceAddress, name="AddrBlk3")
    AddrBlk3.activities.append(SynchCall(dest=Cart, parent=AddrBlk3, name="2Cart"))
    
    choiceAddress.addBlock(AddrBlk1, 1.0 / 3)
    choiceAddress.addBlock(AddrBlk2, 1.0 / 3)
    choiceAddress.addBlock(AddrBlk3, 1.0 / 3)
    
    Addr.getActivities().append(choiceAddress)
    Addr.getActivities().append(Activity(stime=1.0, parent=Addr, name="e"))
    
    # front_end entries logic#
    choiceCatalog = probChoice(parent=Catalog, name="CatalogChoice")
    CatBlk1 = actBlock(parent=choiceCatalog, name="CatBlk1")
    CatBlk1.activities.append(SynchCall(dest=List, parent=CatBlk1, name="2List"))
    CatBlk2 = actBlock(parent=choiceCatalog, name="CatBlk2")
    CatBlk2.activities.append(SynchCall(dest=Item, parent=CatBlk2, name="2Item"))
    
    choiceCatalog.addBlock(CatBlk1, 1.0 / 2)
    choiceCatalog.addBlock(CatBlk2, 1.0 / 2)
    
    Home.getActivities().append(Activity(stime=1.0, parent=Home, name="e"))
    
    Catalog.getActivities().append(choiceCatalog)
    Catalog.getActivities().append(Activity(stime=1.0, parent=Catalog, name="e"))
    
    Cart.getActivities().append(SynchCall(dest=Get, parent=Cart, name="2Get"))
    Cart.getActivities().append(SynchCall(dest=Add, parent=Cart, name="2Add"))
    Cart.getActivities().append(SynchCall(dest=Delete, parent=Cart, name="2Rmv"))
    Cart.getActivities().append(Activity(stime=1.0, parent=Cart, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr, parent=browse, name="2Address"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    mname="atom_final"
    lqn2crn.getCrn({"task":[cTask, Router, Front_end, CatalogSvc, CatalogDB, CartSvc,CartDB], "name":mname})
    
    lqn2crn.toMatlab(outDir="../model/validation")
    
    # validate the model against lqns#
    matV = matlabValidator("../model/validation/%s/lqn.m"%(mname))
    lqnV = lqnsValidator("../model/validation/%s/lqn_t.lqn"%(mname))
    
    X0 = [0 for i in range(44)]
    MU = [0 for i in range(44)]
    NC = [0 for i in range(7)]
    NT = [0 for i in range(7)]
    names = [None] * 44
    rep = 1
    dt = 10.0 ** -1
    TF = 3000 * dt
    
    Tclient = []
    e = []
    mat_v=[]
    lqsim_v=[]
    
    for i in range(10):
        
        
        # %X(32)=XCartQuery_e;
        # %X(33)=XGet_e;
        # %X(37)=XAdd_e;
        # %X(41)=XRemove_e;
        # %X(42)=XCart_e;
        # %X(43)=XAddress_e;
        # %X(44)=XBrowse_browse;
    
        X0[-1] = np.random.randint(low=100, high=400)
    
    
        MU[6] = 1.0 / 0.1  # Home
        names[6] = "Home"
    
        MU[16] = 1.0 / 0.1  # CatQuery
        names[16] = "CatQuery"
        MU[17] = 1.0 / 0.1  # List
        names[17] = "List"
        MU[22] = 1.0 / 0.1  # Item
        names[22] = "Item"
    
        MU[23] = 1.0 / 0.1  # Catalog
        names[23]= "Catalog"
        
        MU[31] = 1.0 / 0.1  # CartQuery
        names[31]= "CartQuery"

        MU[32] = 1.0 / 0.1  # Get
        names[32]= "Get"
        MU[36] = 1.0 / 0.1  # Add
        names[36]= "Add"
        MU[40] = 1.0 / 0.1  # Delete
        names[40]= "Del"
        MU[41] = 1.0 / 0.1  # Cart
        names[41]= "Cart"
        MU[42] = 1.0 / 0.1  # Address
        names[42]= "Address"
        MU[43] = 1.0 / 0.1  # Browse
        names[43]= "Browse"
    
        NC[0] = -1
        NC[1] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NC[2] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NC[3] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NC[4] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NC[5] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NC[6] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NT[0] = -1
        NT[1] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NT[2] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NT[3] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NT[4] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NT[5] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
        NT[6] = np.random.randint(low=int(X0[-1] / 2), high=X0[-1] * 2)
    
        print(X0[-1], NC[1:], NT[1:], i)
    
        T_mat=matV.solveModel(X0, MU, NT, NC, dt,Names=names)
        T_lqns = lqnV.solveModel(X0=X0[-1], NT=NT, NC=NC,Names=names)
        for ent in names:
            if(ent is not None):
                print(ent,T_lqns[ent],T_mat[ent])
                e.append(abs(T_lqns[ent]-T_mat[ent]) * 100 /T_lqns[ent])
    
        mat_v.append(T_mat)
        lqsim_v.append(T_lqns)
    
    
    Path("vdata/%s/"%(mname)).mkdir( parents=True, exist_ok=True )
    sp.savemat("vdata/%s/"%(mname),{"mat":mat_v,"lqsim":lqsim_v})
    #
    # plt.figure()
    # plt.stem(Tclient, linefmt="b", markerfmt="bo", label="lqns")
    # plt.stem(T_mat, linefmt="g", markerfmt="go", label="matlb")
    # plt.legend()
    # plt.savefig("Atom_final-validation.pdf")
    
    plt.figure()
    plt.boxplot(e)
    plt.ylabel("Relative Error(%)")
    plt.savefig("Atom_final-validation.pdf")
    
    print(e)
    # print(Tclient)
    # print(T_mat)
