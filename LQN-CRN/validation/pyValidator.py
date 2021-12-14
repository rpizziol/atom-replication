'''
Created on 11 dic 2021

@author: emilio
'''

from pathlib import Path
from validation import Validator
import numpy as np
import scipy.stats as st
from Gillespie import directMethod
import importlib
import sys
import pandas as pd


class pyValidator(Validator):
    
    modelFilePath = None
    modelDirPath = None
    res = None
    crn = None

    def __init__(self, modelPathStr):
        super().__init__()
        self.modelFilePath = Path(modelPathStr)
        if(self.modelFilePath.exists()):
            self.modelDirPath = self.modelFilePath.parents[0]
        else:
            raise ValueError("File %s not found" % (modelPathStr))
        
        crn_path = str(self.modelDirPath / "lqn").replace("/", ".")
        genlqn_moule = importlib.import_module(str(crn_path).replace("/", "."))
        # cosi carico la CRN generata in formato python
        self.crn = genlqn_moule.pyCRN()
    
    def solveModel(self, X0, MU, NT, NC):
        
        p={"MU":np.matrix(MU),
           "NC":np.matrix(NC),
           "NT":np.matrix(NT),
           "delta":10.0**5}
    
        e=np.infty
        
        #dimensione di un batch
        K=30
        #numrto di batch
        N=30
        B=[]
        dt=0.1
        x0=X0
        while(e>0.5*(10**-1)):
            [t,x]=directMethod(stoich_matrix=self.crn.stoich_matrix, 
                               propensity_fcn=self.crn.prop_func,
                               tspan=[0,K*(N+1)*dt], 
                               x0=x0, params=p)
            try:
                td = pd.Series(index=[pd.Timedelta(value=t[i,0],unit="sec") for i in range(t.shape[0])],data=x[:,0])
                td=td.resample('%.3fS'%(dt)).fillna(method="ffill")
                x0=x[-1,:]
            except:
                continue
        
            
            
            X=td.to_numpy()
            
            if(len(B)>0):
                B=np.vstack((B,np.array([X[K*n:K*(n+1)] for n in range(N+1)])))
            else:
                B=np.array([X[K*n:K*(n+1)] for n in range(N+1)])
    
            Bm=np.mean(B,axis=1,keepdims=True)
            CI=st.t.interval(0.95, len(Bm[1:])-1, loc=np.mean(Bm[1:]), scale=st.sem(Bm[1:]))
            e=abs(np.mean(Bm[1:])-CI[0])
                
            print(e)
    
        print(CI[0],np.mean(Bm[1:]),CI[1])
        return MU[-1]*np.mean(Bm[1:])
        
        
    def getResult(self):
        pass
    

if __name__ == '__main__':
    
    mv = pyValidator("../model/validation/single_task/lqn.m")
    
    X0 = [0 for i in range(4)]
    MU = [0 for i in range(4)]
    NC = [0 for i in range(2)]
    NT = [0 for i in range(2)]
    rep = 1
    dt = 10.0 ** -1
    TF = 300 * dt
    
    X0[3] = 100
    MU[2] = 1
    MU[3] = 1
    NC[0] = -1
    NC[1] = 20
    NT[0] = -1
    NT[1] = 15
    
    T = mv.solveModel(X0, MU, NT, NC, dt)
    print(T)
