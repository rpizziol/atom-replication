'''
Created on 31 gen 2022

@author: emilio
'''

import matlab.engine
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import time
import json
from scipy.io import savemat
from scipy.io import loadmat
from generator.SinGen import SinGen

class sockShop():
    GAres = None
    Tsim  = None
    optNC = None
    optNT = None
    stimes = None
    w = None
    NTNames=["NTrouter","NTfrontend","NTCatalogsvc","NTCartsvc","NTCatalogdb","NTCartdb"]
    NCNames=["NCrouter","NCfrontend","NCCatalogsvc","NCCartsvc","NCCatalogdb","NCCartdb"]

    def __init__(self,gaRes,modelPathStr):
        
        self.GAres=loadmat(gaRes)
        
        self.modelFilePath = Path(modelPathStr)
        if(self.modelFilePath.exists()):
            self.modelDirPath = self.modelFilePath.parents[0]
        else:
            raise ValueError("File %s not found" % (modelPathStr)) 
        
        self.matEng = matlab.engine.start_matlab()
        self.matEng.rng("shuffle","combRecursive")
        self.matEng.cd(str(self.modelDirPath.absolute()))
        
        self.Tsim=[]
        self.optNC=[]
        self.optNT=[]
        self.w =[]
        
    def simulate(self,X0,NT,NC,MU,dt,TF,nrep=1):
        X = self.matEng.lqn(matlab.double(X0), matlab.double(MU),
                          matlab.double(NT), matlab.double(NC), TF, nrep, dt)
        
        return np.array(X)
    
    def startRedis(self):
        pass
    
    def getCtrl(self):
        pass
    
    def startGenecitCtrl(self):
        pass
    
    def startSim(self,samplingPeriod,ctrlPeriod,simLength,nusers,NCinit=None,NTinit=None,isInf=True):
        
        if(samplingPeriod<ctrlPeriod):
            raise ValueError("samplingPeriod needs to be greater of equals to ctrlPeriod")
        
        
        X0=[0 for i in range(49)]
        MU=[-1 for i in range(49)]
        
        dt=1
        TF=ctrlPeriod
        nrep=1
        
        X0[47]=nusers
        
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
        step=int(np.ceil(self.GAres["bestTimeStamps"][0]))
        simTime=0
        
        
        e=[]
        Tstep=[]
        
        while(step<simLength):
            self.w.append(nusers)
            print("step %d"%(step))
            stime=time.time()
            
            NC=None
            NT=[100000]*7
            idx = (np.abs(self.GAres["bestTimeStamps"] - step)).argmin()
            if(idx==0 and step<=self.GAres["bestTimeStamps"][idx]):
                NC=[100000]+[1]*4+[100000]*2
            else:
                NC=[100000]+self.GAres["bestIndividuals"][idx].tolist()+[100000]*2
            
                
            
            self.optNT.append(NT)
            self.optNC.append(NC)
            print(NT)
            print(NC)
            
            X=sys.simulate(X0, NT, NC, MU, dt, TF, nrep)
            time.sleep(max(ctrlPeriod-(time.time()-stime),0))
            #Xsys+=(X[47,:]*MU[47]).tolist()
            Xsys+=[X[48,-1]/(TF*1.0)]
            
            X0=X[:,-1].tolist()
            X0[48]=0
            simTime+=TF
            #if(simTime%samplingPeriod==0):
            
            
            self.Tsim.append(np.mean(Xsys))
            Tstep.append(np.mean(Xsys))
            
            print(Tstep[-1])
            
            Tcum=np.divide(np.cumsum(Tstep),np.linspace(1,len(Tstep),len(Tstep)))[-1]
            e.append(np.abs(Tcum-(nusers*MU[47]))*100/(nusers*MU[47]))
            
            print("error %f%%"%(e[-1]),len(e))
            
            ntime=0
            for ei in range(len(e)-1,0,-1):
                if(e[ei]<=1):
                    if(ntime<20):
                        ntime+=1
                    else:
                        ntime+=1
                        break
                else:
                    ntime=0
            
            if(step-int(np.ceil(self.GAres["bestTimeStamps"][0]))>1010):
                print("***stopping***")
                break
            else:
                print("ntime=%d"%(ntime))
                
            Xsys=[]
            step+=1
                
        
        # stimes=self.r.get("stimes").decode('UTF-8')
        # if(self.stimes is None):
        #     self.stimes=json.loads(stimes)[1:]
        # else:
        #     self.stimes+=json.loads(stimes)[1:]
        
        self.stimes=[0]
        
        return step-int(np.ceil(self.GAres["bestTimeStamps"][0]))
    
        

if __name__ == '__main__':
    
    period=400
    shift=1520
    mod=1500
    step=100000
    sgen=SinGen(period,shift,mod)    
    
    
    W=[2000,1000]
    #for t in range(0,period+20,20):
    for t in range(len(W)):
        w=W[t]
        #w=sgen.getUser(t)
        
        sys=sockShop("data/allbest-%do.mat"%(w),"../model/validation/2task_prob/lqn.m")
        steps=[]
        
        print("############Step=%d#############"%(t))    
        if(True):
            s=sys.startSim(samplingPeriod=1.0, ctrlPeriod=1.0, simLength=step,nusers=w)
        else:
            s=sys.startSim(samplingPeriod=1.0, ctrlPeriod=1.0, simLength=step,nusers=w,NCinit=sys.optNC[-1],NTinit=sys.optNT[-1])
            
        steps.append(s)
    
        savemat("muopt_%d-%s-GA.mat"%(w,"o"), {"Tsim":sys.Tsim,"NT":np.array(sys.optNT)[:,1:5],"NC":np.array(sys.optNC)[:,1:5],"stimes":sys.stimes,
                 "w":sys.w,"steps":steps})