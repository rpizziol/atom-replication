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
    Client_t = Task(name="Client", ref=True)
    Auth_t = Task(name="Auth")
    ValidateId_t = Task(name="ValidateId")
    BookFlight_t = Task(name="BookFlight")
    UpdateMiles_t = Task(name="UpdateMiles")
    CancelBooking_t = Task(name="CancelBooking")
    GetRewardsMiles_t = Task(name="GetRewardsMiles")
    QueryFlight_t = Task(name="QueryFlight")
    ViewProfile_t = Task(name="ViewProfile")
    UpdateProfile_t = Task(name="UpdateProfile")
    
    # entries declaration
    Browse = Entry("Browse")
    Login = Entry("Login")
    Validate = Entry("Validate")
    Book = Entry("Book")
    UpdateMiles = Entry("UpdateMiles")
    Cancel = Entry("Cancel")
    GetReward = Entry("GetReward")
    Query = Entry("Query")
    UpdateProfile = Entry("UpdateProfile")
    ViewProfile = Entry("ViewProfile")
    
    Client_t.addEntry(Browse)
    Auth_t.addEntry(Login)
    ValidateId_t.addEntry(Validate)
    BookFlight_t.addEntry(Book)
    UpdateMiles_t.addEntry(UpdateMiles)
    CancelBooking_t.addEntry(Cancel)
    GetRewardsMiles_t.addEntry(GetReward)
    QueryFlight_t.addEntry(Query)
    ViewProfile_t.addEntry(ViewProfile)
    UpdateProfile_t.addEntry(UpdateProfile)
    
    # activities declaration
    # Client logic#
    Browse.getActivities().append(SynchCall(dest=Login, parent=Browse, name="2Login"))
    Browse.getActivities().append(SynchCall(dest=ViewProfile, parent=Browse, name="2View")) #2 richieste
    Browse.getActivities().append(SynchCall(dest=UpdateProfile, parent=Browse, name="2UpdateProfile"))
    Browse.getActivities().append(SynchCall(dest=Query, parent=Browse, name="2Query"))
    Browse.getActivities().append(SynchCall(dest=Book, parent=Browse, name="2Book"))
    Browse.getActivities().append(SynchCall(dest=Cancel, parent=Browse, name="2Cancel")) #2 richieste
    Browse.getActivities().append(Activity(stime=1.0, parent=Browse, name="e")) 
    
    #Login logic#
    Login.getActivities().append(SynchCall(dest=Validate, parent=Login, name="2Validate"))
    Login.getActivities().append(Activity(stime=1.0, parent=Login, name="e"))
    
    #Validate logic#
    Validate.getActivities().append(Activity(stime=1.0, parent=Validate, name="e"))
    
    #Book logic#
    Book.getActivities().append(SynchCall(dest=UpdateMiles, parent=Book, name="2UpdateMiles")) #2 richieste
    Book.getActivities().append(SynchCall(dest=GetReward, parent=Book, name="2GetReward")) #2 richieste
    Book.getActivities().append(Activity(stime=1.0, parent=Book, name="e"))
    
    #UpdateMiles logic#
    UpdateMiles.getActivities().append(Activity(stime=1.0, parent=UpdateMiles, name="e"))
    
    #GetReward logic#
    GetReward.getActivities().append(Activity(stime=1.0, parent=GetReward, name="e"))
    
    #Cancel logic#
    Cancel.getActivities().append(SynchCall(dest=UpdateMiles, parent=Cancel, name="2UpdateMilesCancel")) 
    Cancel.getActivities().append(SynchCall(dest=GetReward, parent=Cancel, name="2GetRewardCancel"))
    Cancel.getActivities().append(Activity(stime=1.0, parent=Cancel, name="e"))
    
    #Query logic#
    Query.getActivities().append(Activity(stime=1.0, parent=Query, name="e"))
    
    #ViewProfile logic#
    ViewProfile.getActivities().append(Activity(stime=1.0, parent=ViewProfile, name="e"))
    
    #UpdateProfile logic#
    UpdateProfile.getActivities().append(Activity(stime=1.0, parent=UpdateProfile, name="e"))
    
    
    
    lqn2crn = LQN_CRN2()
    lqn2crn.getCrn({"task":[Client_t,Auth_t,ValidateId_t,BookFlight_t,UpdateMiles_t,CancelBooking_t,
                            GetRewardsMiles_t,QueryFlight_t,ViewProfile_t,UpdateProfile_t], "name":"AcmeAir"})
    lqn2crn.toMatlab(outDir="../model/validation/")  
    modelPath=Path("../model/validation/AcmeAir/lqn.m")
    
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
