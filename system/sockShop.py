'''
Created on 31 gen 2022

@author: emilio
'''

import matlab.engine
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import redis
import subprocess
import time
import json
from scipy.io import savemat
from scipy.io import loadmat

class sockShop():
    modelFilePath = None
    modelDirPath = None
    res = None
    matEng = None
    r = None
    Tsim  = None
    optNC = None
    optNT = None
    stimes = None
    NTNames=["NTrouter","NTfrontend","NTCatalogsvc","NTCartsvc","NTCatalogdb","NTCartdb"]
    NCNames=["NCrouter","NCfrontend","NCCatalogsvc","NCCartsvc","NCCatalogdb","NCCartdb"]

    def __init__(self, modelPathStr):
        self.modelFilePath = Path(modelPathStr)
        if(self.modelFilePath.exists()):
            self.modelDirPath = self.modelFilePath.parents[0]
        else:
            raise ValueError("File %s not found" % (modelPathStr)) 
        self.matEng = matlab.engine.start_matlab()
        self.matEng.rng("shuffle","combRecursive")
        self.matEng.cd(str(self.modelDirPath.absolute()))
        self.r=redis.Redis()
    
    def simulate(self,X0,NT,NC,MU,dt,TF,nrep=1):
        X = self.matEng.lqn(matlab.double(X0), matlab.double(MU),
                          matlab.double(NT), matlab.double(NC), TF, nrep, dt)
        
        return np.array(X)
    
    def startRedis(self):
        pass
    
    def getCtrl(self):
        pass
    
    def startOptCtrl(self):
        return subprocess.Popen(["julia","../LQN-CRN/controller/2task_prob/MADNLP.jl"])
    
    def startGenecitCtrl(self):
        pass
    
    def reset(self):
        self.r.delete("Tr")
        self.r.delete("w")
        for i in range(len(self.NCNames)):
            self.r.delete(self.NTNames[i])
            self.r.delete(self.NCNames[i])
    
    def startSim(self,samplingPeriod,ctrlPeriod,simLength):
        
        if(samplingPeriod<ctrlPeriod):
            raise ValueError("samplingPeriod needs to be greater of equals to ctrlPeriod")
        
        self.reset()
        
        X0=[0 for i in range(49)]
        MU=[-1 for i in range(49)]
        
        dt=0.01
        TF=ctrlPeriod
        nrep=1
        
        X0[47]=3000
        
        MU[17]=1.0/(2.2*10**-3) #LIST
        MU[22]=1.0/(1.9*10**-3) #ITEM
        
        MU[6]=1.0/(2.1*10**-3) #Home
        MU[23]=1.0/(3.7*10**-3) #Catalog
        MU[45]=1.0/(5.1*10**-3) #Carts
        
        MU[34]= 1.0/(4.8*10**-3)  #Get
        MU[39]= 1.0/(17.4*10**-3) #Add
        MU[44]= 1.0/(5.6*10**-3)  #Del
        
        MU[16]=1.0/(1.3*10**-3) #CatQry
        MU[33]=1.0/(2.2*10**-3) #CartQry
        
        MU[46]=1.0/(1.2*10**-3) #Address
        MU[47]=1.0/7 #think
        
        Xsys=[]
        self.Tsim=[]
        self.optNC=[]
        self.optNT=[]
        step=0
        simTime=0
        self.r.set("w",X0[47])
        
        P=self.startOptCtrl()
        
        self.r.set("started","0")
        while(self.r.get("started").decode('UTF-8')=="0"):
            print("waint julia to start")
            time.sleep(0.5)
        print("started")
        
        while(step<simLength):
            print("step %d"%(step))
            stime=time.time()
            
            #aggiorno i controlli
            NT=[10000]+list(map(lambda x: 10 if x is None else int(x), self.r.mget(self.NTNames)))
            NC=[10000]+list(map(lambda x: 10 if x is None else float(x), self.r.mget(self.NCNames)))
            #NT=np.ceil([10000,10000,10000,10000,10000,1000,1000]).tolist()
            #NC=[10000,0.7333,1.5276,0.4644,0.3570,1000,1000]
            
            self.optNT.append(NT)
            self.optNC.append(NC)
            print(NT)
            print(NC)
            
            X=sys.simulate(X0, NT, NC, MU, dt, TF, nrep)
            time.sleep(max(ctrlPeriod-(time.time()-stime),0))
            Xsys+=(X[47,:]*MU[47]).tolist()
            
            X0=X[:,-1].tolist()
            #print(X0)
            X0[48]=0
            simTime+=TF
            #if(simTime%samplingPeriod==0):
            
            self.Tsim.append(np.mean(Xsys))
            self.r.set("Tr",str(self.Tsim[-1]))
            self.r.set("w",X0[47]+X0[0])
            print(np.divide(np.cumsum(sys.Tsim),np.linspace(1,len(sys.Tsim),len(sys.Tsim)))[-1])
            Xsys=[]
            step+=1
                
        P.terminate()
        
        stimes=self.r.get("stimes").decode('UTF-8')
        self.stimes=json.loads(stimes)
        

if __name__ == '__main__':
    
    
    sys=sockShop("../model/validation/2task_prob/lqn.m")
    sys.startSim(samplingPeriod=1.0, ctrlPeriod=1.0, simLength=1000)
    
    
    plt.figure()
    plt.plot(sys.Tsim)
    plt.plot(np.divide(np.cumsum(sys.Tsim),np.linspace(1,len(sys.Tsim),len(sys.Tsim))))
    plt.axhline(3000*(1.0/7.005))
    
    plt.figure()
    plt.plot(np.array(sys.optNT)[:,1:4])
    
    plt.figure()
    plt.plot(np.array(sys.optNC)[:,1:4])
    
    plt.show()