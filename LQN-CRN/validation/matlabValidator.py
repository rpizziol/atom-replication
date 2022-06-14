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
import time


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
    
    def solveModel(self, X0, MU, NT, NC, dt=0.1, Names=None, TF=None, rep=None,EntryTaskMapping=None):
        
        self.matEng.clear
        e = np.infty
        
        tIdx = np.where(np.array(Names) != None)[0]
    
        # dimensione di un batch
        K = 50
        # numrto di batch
        N = 50
        B = None
        
        #recuper tutte le entry del modello
        entriesName=set([name.split("_")[0] for name in Names])
        entriesWaiting={}
        for idx,val in enumerate(entriesName):
            #per ogni entry recupero tutti i thread occupati (sperimentale)
            entriesWaiting[val]=[];
            for name in Names:
                if(name.split("_")[0]==val and name not in entriesWaiting[val] and not name.endswith("_a")):
                    entriesWaiting[val].append(name)
        
        while(e > 0.05 * 10 ** -1):
            
            X = self.matEng.lqn(matlab.double(X0), matlab.double(MU),
                          matlab.double(NT), matlab.double(NC), K * (N + 1) * dt, 1, dt)
            X = np.array(X)
            X0 = X[:, -1].tolist()
            
            if B is None: 
                B = [[] for cmp in range(X.shape[0])]
            
            for cmp in range(X.shape[0]):
                if(len(B[cmp]) > 0):
                    B[cmp] = np.vstack((B[cmp], np.array([X[cmp, K * n:K * (n + 1)].tolist() for n in range(N + 1)])))
                else:
                    B[cmp] = np.array([X[cmp, K * n:K * (n + 1)].tolist() for n in range(N + 1)])

            Bm2 = np.mean(B, axis=2)
            # Bm=np.mean(B[-1],axis=1,keepdims=True)
            # CI=st.t.interval(0.95, len(Bm[1:])-1, loc=np.mean(Bm[1:]), scale=st.sem(Bm[1:]))
            # e=abs(np.mean(Bm[1:])-CI[0])
            
            es=[]
            
            for idxe in range(Bm2.shape[0]):
                CI = st.t.interval(0.99, len(Bm2[idxe, 1:]) - 1, loc=np.mean(Bm2[idxe, 1:]), scale=st.sem(Bm2[idxe, 1:]))
                es.append(abs(np.mean(Bm2[idxe, 1:]) - CI[0]))
            
            Rts=[]
            #calcolo gli errori sui tempi di riposta
            for idx,val in enumerate(entriesName):
                #recupero tutte le lunghezze di coda di questa entry
                qIdx=[]
                eIdx=None
                for n in entriesWaiting[val]:
                    qIdx+=[Names.index(n)]
                    if(n.endswith("_e") or n.endswith("browse")):
                        eIdx=Names.index(n)
                    
                #print(val,qIdx,eIdx)
                q=0;
                for i in qIdx:
                    q+=Bm2[i, 1:]
                
                if(NC[EntryTaskMapping[eIdx]]!=-1):
                    Ti=np.minimum(np.mean(Bm2[eIdx, 1:]),NC[EntryTaskMapping[eIdx]])*MU[eIdx]
                else:
                    Ti=np.mean(Bm2[eIdx, 1:])*MU[eIdx]
                    
                Rts.append(np.divide(q,Ti))
            
            for rt in Rts:
                CI = st.t.interval(0.99, len(rt) - 1, loc=np.mean(rt), scale=st.sem(rt))
                es.append(abs(np.mean(np.mean(rt) - CI[0])))
                
            e=np.nanmax(es)
            print(entriesName)
            print(np.mean(np.array(Rts),axis=1))
            
        # print([MU[idx] * np.mean(Bm2[idx, 1:]) for idx in tIdx])
        res = {}
        for idx in tIdx:
            # questa cosa e vera solo per la think station, per le altre entry mi dovrei riportare il numero di core e riscalare il tutto
            # anche in funzione delle altre entry che usano la stessa CPU
            res[Names[idx]] = np.mean(Bm2[idx, 1:])
        
        return res
    
    def solveModelIt(self, X0, MU, NT, NC, dt=0.1, Names=None, TF=None, rep=None): 
        X = self.matEng.lqn(matlab.double(X0), matlab.double(MU),
                          matlab.double(NT), matlab.double(NC), TF, rep, dt)
        X = np.array(X)
        return X
    
    def getResult(self):
        pass
    

if __name__ == '__main__':
    mv = matlabValidator("../model/validation/2task/lqn.m")
    
    X0 = [0 for i in range(7)]
    MU = [0 for i in range(7)]
    NC = [0 for i in range(3)]
    NT = [0 for i in range(3)]
    rep = 1
    dt = 10.0 ** -1
    TF = 300 * dt
    
    X0[-1] = 200
    MU[4] = 1.
    MU[5] = 100.
    MU[6] = 1.
    
    NC[0] = -1
    NC[1] = 1
    NC[2] = 1
    
    NT[0] = -1
    NT[1] = 10000
    NT[2] = 10000
    
    Names=["XBrowse_2Address","XAddress_a","XAddress_2Home","XHome_a","XHome_e","XAddress_e","XBrowse_browse"]
    
    
    T = mv.solveModel(X0, MU, NT,NC, dt,Names=Names,EntryTaskMapping=[0,1,1,2,2,1,0])
    
    print(T["XAddress_a"],T["XAddress_2Home"],T["XAddress_e"])
    print(min(T["XAddress_e"],NC[1])*MU[5])
    
    RT0=(T["XBrowse_2Address"]+T["XBrowse_browse"])/(T["XBrowse_browse"]*MU[6])
    RT1=(T["XAddress_a"]+T["XAddress_2Home"]+T["XAddress_e"])/(np.minimum(T["XAddress_e"],NC[1])*MU[5])
    RT2=(T["XHome_a"]+T["XHome_e"])/(np.minimum(T["XHome_e"],NC[2])*MU[4]);
    
    
    print([0,T["XBrowse_browse"],T["XAddress_a"],T["XAddress_e"],T["XHome_a"],T["XHome_e"]])
    print([RT0,RT1,RT2])
