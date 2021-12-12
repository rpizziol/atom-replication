'''
Created on 11 dic 2021

@author: emilio
'''

import matlab.engine
from pathlib import Path
from validation import Validator
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st


class matlabValidator(Validator):
    
    modelFilePath = None
    modelDirPath = None
    res = None
    matEng = None

    def __init__(self, modelPathStr):
        super().__init__()
        self.modelFilePath = Path(modelPathStr)
        if(self.modelFilePath.exists()):
            self.modelDirPath = self.modelFilePath.parents[0]
        else:
            raise ValueError("File %s not found" % (modelPathStr))
        self.matEng = matlab.engine.start_matlab()
        self.matEng.cd(str(self.modelDirPath.absolute()))
    
    def solveModel(self, X0, MU, NT, NC,dt,TF=None, rep=None):
        
        self.matEng.clear
        e=np.infty
        
        #dimensione di un batch
        K=30
        #numrto di batch
        N=30
        B=[]
        while(e>0.5*10**-1):
            X = self.matEng.lqn(matlab.double(X0),matlab.double(MU),
                          matlab.double(NT),matlab.double(NC),K*(N+1)*dt, 1, dt)
            X=np.array(X)
            X0=X[:,-1].tolist()
            
            if(len(B)>0):
                B=np.vstack((B,np.array([X[-1,K*n:K*(n+1)].tolist() for n in range(N+1)])))
            else:
                B=np.array([X[-1,K*n:K*(n+1)].tolist() for n in range(N+1)])
                
            Bm=np.mean(B,axis=1,keepdims=True)
            CI=st.t.interval(0.95, len(Bm[1:])-1, loc=np.mean(Bm[1:]), scale=st.sem(Bm[1:]))
            e=abs(np.mean(Bm[1:])-CI[0])
            
            print(e)
        
        return MU[-1]*np.mean(Bm[1:])
        
    def getResult(self):
        pass
    

if __name__ == '__main__':
    mv = matlabValidator("../model/validation/single_task/lqn.m")
    
    X0 = [0 for i in range(4)]
    MU = [0 for i in range(4)]
    NC = [0 for i in range(2)]
    NT = [0 for i in range(2)]
    rep = 1
    dt = 10.0 ** -1
    TF = 300*dt
    
    X0[3] = 100
    MU[2] = 1
    MU[3] = 1
    NC[0] = -1
    NC[1] = 20
    NT[0] = -1
    NT[1] = 15
    
    T=mv.solveModel(X0, MU, NT, NC, dt)
    print(T)