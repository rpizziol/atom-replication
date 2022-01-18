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
from astropy.units import GR
        
if __name__ == '__main__':
    
    # task declaration
    cTask = Task(name="Client", ref=True)
    Router = Task(name="Router")
    Front_end = Task(name="Front_end")
    CatSvc = Task(name="CatSvc")
    CatStore = Task(name="CatStore")
    CartSvc = Task(name="CartSvc")
    
    
    # entries declaration
    browse = Entry("Browse")
    
    Addr = Entry("Address")
    
    Home = Entry("Home")
    Catalog = Entry("Catalog")
    Cart = Entry("Cart")
    
    CatQry = Entry("CatQry")
    
    List = Entry("List")
    Item = Entry("Item")
    
    Get = Entry("Get")
    Add = Entry("Add")
    Rmv = Entry("Rmv")
    
    cTask.addEntry(browse)
    Router.addEntry(Addr)
    Front_end.addEntry(Home)
    Front_end.addEntry(Catalog)
    Front_end.addEntry(Cart)
    
    CatSvc.addEntry(List)
    CatSvc.addEntry(Item)
    
    #CatStore.addEntry(CatQry)
    
    CartSvc.addEntry(Get)
    CartSvc.addEntry(Add)
    CartSvc.addEntry(Rmv)
    
    # activity declaration
    
    #catDB
    CatQry.getActivities().append(Activity(stime=1.0, parent=CatQry, name="e"))
    
    # CatSvc  entries logic#
    #List.getActivities().append(SynchCall(dest=CatQry, parent=List, name="List2CatQry"))
    List.getActivities().append(Activity(stime=1.0, parent=List, name="e"))
    # Item.getActivities().append(SynchCall(dest=CatQry, parent=Item, name="Item2CatQry"))
    Item.getActivities().append(Activity(stime=1.0, parent=Item, name="e"))
    
    # CartSvc  entries logic#
    Get.getActivities().append(Activity(stime=1.0, parent=Get, name="e"))
    Add.getActivities().append(Activity(stime=1.0, parent=Add, name="e"))
    Rmv.getActivities().append(Activity(stime=1.0, parent=Rmv, name="e"))
    
    # Router  entries logic#
    choiceAddress=probChoice(parent=Addr, name="Choice")
    
    BlkHome=actBlock(parent=choiceAddress, name="BlkHome")
    BlkHome.activities.append(SynchCall(dest=Home, parent=BlkHome, name="2Home"))
    
    BlkCatalog=actBlock( parent=choiceAddress, name="BlkCatalog")
    BlkCatalog.activities.append(SynchCall(dest=Catalog, parent=BlkCatalog, name="2Catalog"))
    
    BlkCart=actBlock( parent=choiceAddress, name="BlkCart")
    BlkCart.activities.append(SynchCall(dest=Cart, parent=BlkCart, name="2Cart"))
    
    choiceAddress.addBlock(BlkHome, 1.0/3)
    choiceAddress.addBlock(BlkCatalog, 1.0/3)
    choiceAddress.addBlock(BlkCart, 1.0/3)
    
    Addr.getActivities().append(choiceAddress)
    Addr.getActivities().append(Activity(stime=1.0, parent=Addr, name="e"))
    
    # front_end entries logic#
    Home.getActivities().append(Activity(stime=1.0, parent=Home, name="e"))
    
    choiceCat=probChoice(parent=Catalog, name="choiceCatalog")
    blkList=actBlock(parent=choiceCat, name="blkList")
    blkList.getActivities().append(SynchCall(dest=List, parent=blkList, name="2List"))
    blkItem=actBlock(parent=choiceCat, name="blkItem")
    blkItem.getActivities().append(SynchCall(dest=Item, parent=blkItem, name="2Item"))
    
    choiceCat.addBlock(blkList, 1.0/2)
    choiceCat.addBlock(blkItem,1.0/2)
    
    Catalog.getActivities().append(choiceCat)
    Catalog.getActivities().append(Activity(stime=1.0, parent=Catalog, name="e"))
    
    choiceCart=probChoice(parent=Cart, name="choiceCart")
    blkGet=actBlock(parent=choiceCart, name="BlkGet")
    blkGet.getActivities().append(SynchCall(dest=Get, parent=blkGet, name="2Get"))
    blkAdd=actBlock(parent=choiceCart, name="BlkAdd")
    blkAdd.getActivities().append(SynchCall(dest=Add, parent=blkAdd, name="2Add"))
    blkRmv=actBlock(parent=choiceCart, name="BlkRmv")
    blkRmv.getActivities().append(SynchCall(dest=Rmv, parent=blkRmv, name="2Rmv"))
    
    choiceCart.addBlock(blkGet, 1.0/3)
    choiceCart.addBlock(blkAdd, 1.0/3)
    choiceCart.addBlock(blkRmv, 1.0/3)
    
    Cart.getActivities().append(choiceCart)
    Cart.getActivities().append(Activity(stime=1.0, parent=Cart, name="e"))
    
    # client logic#
    browse.getActivities().append(SynchCall(dest=Addr, parent=browse, name="2Address"))
    browse.getActivities().append(Activity(stime=1.0, parent=browse, name="browse"))
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[cTask, Router,Front_end,CatSvc,CartSvc], "name":"2task_prob"})
    
    #lqn2crn.toCasadiCtrl(outDir="./controller")
    lqn2crn.toMatlab(outDir="../model/validation")
    lqn2crn.toJuliaCtrl(outDir="./controller/julia")
    
    # # validate the model against lqns#
    # matV = matlabValidator("../model/validation/2task_prob/lqn.m")
    # lqnV = lqnsValidator("../model/validation/2task_prob/lqn_t.lqn")
    #
    # X0 = [0 for i in range(13)]
    # MU = [0 for i in range(13)]
    # NC = [0 for i in range(3)]
    # NT = [0 for i in range(3)]
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
    #     MU[6] = 1
    #     MU[10] = 1
    #     MU[11] = 1
    #     MU[12] = 1
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
    # plt.savefig("2task_prob-validation.pdf")
    #
    # print(e)
    # print(Tclient)
    # print(T_mat)