'''
Created on 9 dic 2021

@author: emilio
'''

import traceback
from entity import Activity,AsynchCall, actBlock, SynchCall, probChoice, Call
import numpy as np
import json
from jinja2 import Environment, PackageLoader, select_autoescape
from pathlib import Path
import sys
import entity
import os
import re
import copy

script_dir = Path(os.path.realpath(__file__))/".."/".."


def hilite(string, status, bold):
    attr = []
    if status:
        # green
        attr.append('32')
    else:
        # red
        attr.append('31')
    if bold:
        attr.append('1')
    return '\x1b[%sm%s\x1b[0m' % (';'.join(attr), string)


class LQN_CRN2():
    
    Jumps = None
    props = None
    names = None
    rates = None
    lqn = None
    mapState = None
    genJump = None
    genProp = None
    
    def __init__(self):
        self.Jumps = []
        self.props = []
        self.names = []
        self.mapState = False
        self.genJump = False
        self.genProp = False
        self.rates = {}
    
    def findAct(self, aname, parent, ename=None):
        a_tgt = None
        for a in parent.getActivities():
            if((ename == a.getParentEntry().name and a.name == aname) or (a.name == aname and ename is None) 
               or (ename == a.getParentEntry().name and aname == "a")):
                a_tgt = a
            else:
                if(isinstance(a, Call)):
                    a_tgt = self.findAct(aname, a.dest, ename)
                else:
                    a_tgt = self.findAct(aname, a, ename)
            if(a_tgt is not None):
                break
            
        return a_tgt
    
    # mapp ogni activity nell'opportuno stato
    # la filosofia e di fare una visita in profondita
    # a seconda del tipo di activity recupero la prossima activity da visitare
    def mapStateName(self, act):
        # print("activity:" + act.name, "Entry:" + act.getParentEntry().name,
        #       "Task:" + act.getParentTask().name)
        
        # se e' la prima activity della sua parentEntry aggiunfo l'activity che mi rappresenta 
        # le variabili in coda di acquisizione in una data entry
        if(act.getParentEntry().getActivities()[0] == act and not act.getParentTask().ref):
            if("X%s_a" % (act.getParentEntry().name) not in self.names):
                self.names.append("X%s_a" % (act.getParentEntry().name))
        
        if("X%s_%s" % (act.getParentEntry().name, act.name) not in self.names):
            self.names.append("X%s_%s" % (act.getParentEntry().name, act.name))
            
        if(isinstance(act, SynchCall)):
            for a in act.dest.getActivities():
                self.mapStateName(a)
        elif(isinstance(act, AsynchCall)):
            for a in act.dest.getActivities():
                self.mapStateName(a)
        elif(isinstance(act, probChoice)):
            for a in act.getActivities():
                self.mapStateName(a)
        elif(isinstance(act, actBlock)):
            #print(act.name,len(act.getActivities()))
            for a in act.getActivities():
                #print("\t"+a.name,a.dest.name,a.getParentEntry().name)
                self.mapStateName(a)
    
    def createJump(self, sndName, lrcvName, rrcvName, rsyncName):
        jump = [0 for i in range(len(self.names))]
        
        jump[self.names.index(sndName)] = -1
        if(type(lrcvName) is list):
            for lrcv in lrcvName:
                jump[self.names.index(lrcv)] = 1
        else:
            jump[self.names.index(lrcvName)] = 1
        
        if(rrcvName is not None):
            jump[self.names.index(rrcvName)] = +1
        
        if(rsyncName is not None):
            jump[self.names.index(rsyncName)] = -1
        
        #verifico che il jump non esiste gia nella matrice
        if(jump not in self.Jumps):
            self.Jumps.append(jump)
    
    def createPropensity(self, jump):
        # per semplicita cerco di determinare la propensita a partire dal jump
        # e le assunzione che ho fatto sul modello
        frm = []
        to = []
        for i in range(len(jump)):
            if(jump[i] != 0):
                # parto sempre dall'unica entry del client task
                #act = self.findAct(aname, self.lqn["task"][0].getEntries()[0], ename)
                if(jump[i] > 0):
                    to.append(self.names[i])
                else:
                    frm.append(self.names[i])
        
        print(",".join(frm),"->",",".join(to))
        
        syncall=None
        for f in frm:
            ename=f.split("_")[0][1:]
            aname=f.split("_")[1]
            act = self.findAct(aname, self.lqn["task"][0].getEntries()[0], ename)
            if(isinstance(act,SynchCall)):
                syncall=act
                break
        
        for f in frm:
            act=None
            ename=f.split("_")[0][1:]
            aname=f.split("_")[1]
            if(f.endswith("_a")):
                #caso in cui vengo da un acquire (in questo caso posso andare solo in una zione locale)
                act = self.findAct(aname, self.lqn["task"][0].getEntries()[0], ename)
                # TBD propensity delle reazioni che si sincronizzano con un thread libero#
                prop = "X%s_a/(%s)" % (act.getParentEntry().name,
                                        "+".join(["X%s_a" % (e.name) for e in act.getParentTask().getEntries()]))
                prop += "*D*min(%s,NT[\"%s\"]-(%s))" % ("+".join(["X%s_a" % (e.name) for e in act.getParentTask().getEntries()]),
                                       act.getParentTask().name,
                                       "+".join(["X%s_%s" % (a.getParentEntry().name, a.name) for e in act.getParentTask().getEntries() for a in e.getAllActivities()]))
                self.props.append(prop)
                break
            else:
                #caso in cui vengo da una qualsiasi altra istruzione
                #devo distinguere due casi
                #il caso di una scelta probabilistica
                #   probChoice->actBlock
                #   actBlock->activity
                act  = self.findAct(aname, self.lqn["task"][0].getEntries()[0], ename)
                act1 = self.findAct(to[0].split("_")[1], self.lqn["task"][0].getEntries()[0], to[0].split("_")[0][1:])  
                prop="-"
                #per sicurezza dovrei analizzare queste condizioni sull'intero jump e non solo sul primo che incontro anche se cosi 
                #dovrebbe funzionare per via dell'ordinamento che la visita in profondita da agli stati della CRN
                if(isinstance(act,probChoice)):
                    prop="D*X%s_%s*%s"%(act.getParentEntry().name,act.name,act.probs[act.getActivities().index(act1)])
                elif(isinstance(act,actBlock)):
                    prop="D*X%s_%s"%(act.getParentEntry().name,act.name)
                #elif(isinstance(act,SynchCall)):
                elif(syncall is not None):
                    #prop=hilite("SynchCall", False, True)
                    act=syncall
                    J = np.matrix(self.Jumps)
                    #recupero la enty destizaione di questa chimata
                    inIdx = np.where(J[:, self.names.index("X%s_a" % act.dest.name)] == 1)
                    
                    #vado alla ricerca di tutte le activity  (synchCall) che si sono sincronizzate con questa entry
                    callingAct = []
                    for idx in inIdx[0]:
                        for n in np.where(J[idx,:] == 1)[1].tolist():
                            a = self.findAct(aname=self.names[n].split("_")[-1],parent=self.lqn["task"][0].getEntries()[0])
                            if(isinstance(a, SynchCall)):
                                callingAct.append("X%s_%s" % (a.getParentEntry().name, a.name))
                    
                    sndName="X%s_%s" %(act.getParentEntry().name,act.name)
                    rsyncName=None
                    synA=None
                    for rsyncName in frm:
                        synA=self.findAct(aname=rsyncName.split("_")[1],parent=self.lqn["task"][0].getEntries()[0],ename=rsyncName.split("_")[0][1:])
                        if(isinstance(synA,entity.SynchCall) or isinstance(synA,entity.probChoice) or 
                           isinstance(synA,entity.actBlock)):
                            continue
                        else:
                            
                            break
                    
                    #print(jump)
                    #print("cc",rsyncName,synA.getParentTask().name)
                    
                    
                    prop = "%s/(%s)*%s/(%s)*min(%s,NC[\"%s\"])*MU[\"%s\"]" % (sndName,
                                                                "+".join(callingAct),
                                                                rsyncName,
                                                                "+".join(["X%s_e" % (e.name) for e  in synA.getParentTask().entries]),
                                                                "+".join(["X%s_e" % (e.name) for e  in synA.getParentTask().entries]),
                                                                synA.getParentTask().name
                                                                , rsyncName)
                elif(isinstance(act,entity.Activity)):
                    if(not act.getParentTask().ref):
                        
                        raise ValueError("Problem with the model, there is an activity that is not part of the client")
                    
                    prop = "MU[\"X%s_%s\"]*X%s_%s" % (act.getParentEntry().name, act.name,
                                                  act.getParentEntry().name, act.name)
                    
                self.props.append(prop)    
                break         
    
    def mapJump(self, act):
        # print("activity:"+act.name, "Entry:"+act.getParentEntry().name, 
        #       "Task:"+act.getParentTask().name)
        
        # GUARDO L'ISTRUZIONE PRECEDENTE (SICCOME NON HO L'ACQUIRE ESPLICITO L'ISTRUZIONE PRECEDENTE e per forza locale)
        
        idx = act.getParent().getActivities().index(act)
        sndName = None  # id dello stato locale da cui sottrarre (instruzione precedente)
        lrcvName = None  # id dello stato da locale a cui aggiungere (istruzione successiva)
        rrcvName = None  # id dello stato remoto a cui aggiungere (istruzione eseguita sul server remoto)
        rsyncName = None  # id dello stato remoto con cui mi sincronizzo (istruzione con cui mi sincronizzo)
        
        # l'istruzione che riceve e sempre quella corrente
        lrcvName = "X%s_%s" % (act.getParentEntry().name, act.name)
        
        prvact = act.prev()
        
        if(len(prvact) > 1):
            # il caso in cui il numero di azioni senders e maggiori di uno
            for a in prvact:
                sndName = "X%s_%s" % (a.getParentEntry().name, a.name)
    
                if(isinstance(act, Call)):
                    rrcvName = "X%s_a" % (act.dest.name)
                if(isinstance(a, SynchCall)):
                    rsyncName = "X%s_e" % (a.dest.name)
                if(isinstance(a, AsynchCall)):
                    pass
                
                self.createJump(sndName, lrcvName, rrcvName, rsyncName)
                
        else:
            if(len(prvact) == 1):
                sndName = "X%s_%s" % (prvact[0].getParentEntry().name, prvact[0].name)
            else:
                sndName = "X%s_a" % ((act.getParentEntry().name))
            
            if(isinstance(act, Call)):
                rrcvName = "X%s_a" % (act.dest.name)
                if(isinstance(act, AsynchCall)):
                    lrcvName=[lrcvName,"X%s_%s"%(act.getParentEntry().name,act.getParent().getActivities()[idx+1].name)]
                    
            if(len(prvact) == 1 and isinstance(prvact[0], SynchCall)):
                rsyncName = "X%s_e" % (prvact[0].dest.name)
           
            self.createJump(sndName, lrcvName, rrcvName, rsyncName)
            
        if(isinstance(act, SynchCall)):
            for a in act.dest.getActivities():
                self.mapJump(a)
        elif(isinstance(act, AsynchCall)):
            #da rendere asincrona
            for a in act.dest.getActivities():
                self.mapJump(a)
        elif(isinstance(act, probChoice)):
            for a in act.getActivities():
                self.mapJump(a)
        elif(isinstance(act, actBlock)):
            for a in act.getActivities():
                self.mapJump(a)
                
    def mapProp(self):
        for j in self.Jumps:
            self.createPropensity(j)
        
    def getCrn(self, lqn):
        self.lqn = lqn
        try:
            #assumo che il primo task sia quello dei client
            ref = self.lqn["task"][0].getEntries()[0]
            for a in ref.getActivities():
                self.mapStateName(a)
            
            for a in ref.getActivities():
                self.mapJump(a)
            
            #self.mapProp()
            
            
        except:
            traceback.print_exc()
    
    def dumpToFile(self):
        crn = {"Jump":self.Jumps, "Prop":self.props, "State":self.names}
        y = json.dumps(crn)
        print(y)
    
    def toMatlab(self, outDir=None):
        if(outDir == None):
            outDir = "../model"
            
        env = Environment(
            loader=PackageLoader('trasducer', 'templates'),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=False,
            lstrip_blocks=False)
        
        tname = [t.name for t in self.lqn["task"]]
        
        mprops = []
        for p in self.props:
            np = p
            for tn in tname:
                np = np.replace("NC[\"%s\"]" % (tn), "p.NC(%d)" % (tname.index(tn) + 1))
                np = np.replace("NT[\"%s\"]" % (tn), "p.NT(%d)" % (tname.index(tn) + 1))
            for vname in self.names:
                np = np.replace("MU[\"%s\"]" % (vname), "p.MU(%d)" % (self.names.index(vname) + 1))
            for vname in self.names:
                np = np.replace(vname, "X(%d)" % (self.names.index(vname) + 1))
            np = np.replace("D", "p.delta")
            mprops.append(np)
        
        mat_tmpl = env.get_template('model-tpl.m')
        model = mat_tmpl.render(task=self.lqn["task"], name=self.lqn["name"],
              names=self.names, props=mprops, jumps=self.Jumps)
        
        outd = Path(outDir)
        outd = outd / self.lqn["name"]
        outd.mkdir(parents=True, exist_ok=True)
        
        mfid = open("%s/lqn.m" % str(outd.absolute()), "w+")
        mfid.write(model)
        mfid.close()
        
        #++export ODE
        mat_tmpl = env.get_template('modelODE-tpl.m')
        model = mat_tmpl.render(task=self.lqn["task"], name=self.lqn["name"],
              names=self.names, props=mprops, jumps=self.Jumps)
        
        outd = Path(outDir)
        outd = outd / self.lqn["name"]
        outd.mkdir(parents=True, exist_ok=True)
        
        mfid = open("%s/lqnODE.m" % str(outd.absolute()), "w+")
        mfid.write(model)
        mfid.close()
        
    
    def toPython(self, outDir=None):
        if(outDir == None):
            outDir = "../model"
            
        env = Environment(
            loader=PackageLoader('trasducer', 'templates'),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=False,
            lstrip_blocks=False)
        
        tname = [t.name for t in self.lqn["task"]]
        
        mprops = []
        for p in self.props:
            np = p
            for tn in tname:
                np = np.replace("NC[\"%s\"]" % (tn), "p[\"NC\"][0,%d]" % (tname.index(tn)))
                np = np.replace("NT[\"%s\"]" % (tn), "p[\"NT\"][0,%d]" % (tname.index(tn)))
                np = np.replace("min(", "np.minimum(")
                np = np.replace("D", "p[\"delta\"]")
            for vname in self.names:
                np = np.replace("MU[\"%s\"]" % (vname), "p[\"MU\"][0,%d]" % (self.names.index(vname)))
            for vname in self.names:
                np = np.replace(vname, "X[%d]" % (self.names.index(vname)))
            mprops.append(np)
        
        mat_tmpl = env.get_template('pyCRN-tpl.py')
        model = mat_tmpl.render(task=self.lqn["task"], name=self.lqn["name"],
              names=self.names, props=mprops, jumps=self.Jumps)
        
        outd = Path(outDir)
        outd = outd / self.lqn["name"]
        outd.mkdir(parents=True, exist_ok=True)
        mfid = open("%s/lqn.py" % str(outd.absolute()), "w+")
        mfid.write(model)
        mfid.close()
        
        mfid = open("%s/__init__.py" % str(outd.absolute()), "w+")
        mfid.write("from .lqn import *\n")
        mfid.close()
        
    def toCasadiCtrl(self, outDir=None):
        if(outDir == None):
            outDir = "."
            
        env = Environment(
            loader=PackageLoader('trasducer', 'templates'),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=False,
            lstrip_blocks=False)
        
        tname = [t.name for t in self.lqn["task"]]
        
        mprops = []
        for p in self.props:
            np = p
            for tn in tname:
                np = np.replace("NC[\"%s\"]" % (tn), "NC[0,%d]" % (tname.index(tn)))
                np = np.replace("NT[\"%s\"]" % (tn), "NT[0,%d]" % (tname.index(tn)))
            for vname in self.names:
                np = np.replace("MU[\"%s\"]" % (vname), "MU[0,%d]" % (self.names.index(vname)))
            for vname in self.names:
                np = np.replace(vname, "X[%d]" % (self.names.index(vname)))
            np = np.replace("*min(", "*casadi.fmin(")
            if("D" in np):
                np = np.replace("D", "F*delta")
            else:
                np="(1-F)*%s"%(np)
            mprops.append(np)
        
        mat_tmpl = env.get_template('casadiCtrl-tpl.py')
        model = mat_tmpl.render(task=self.lqn["task"], name=self.lqn["name"],
              names=self.names, props=mprops, jumps=self.Jumps)
        
        outd = Path(outDir)
        outd = outd / self.lqn["name"]
        outd.mkdir(parents=True, exist_ok=True)
        mfid = open("%s/lqnCtrl.py" % str(outd.absolute()), "w+")
        mfid.write(model)
        mfid.close()
        
        mfid = open("%s/__init__.py" % str(outd.absolute()), "w+")
        mfid.write("from .lqnCtrl import *\n")
        mfid.close()
        
    def toJuliaCtrl(self,outDir=None):
        
        if(outDir == None):
            outDir = "."
            
        env = Environment(
            loader=PackageLoader('trasducer', 'templates'),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=False,
            lstrip_blocks=False)
        
        print(self.names)
        
        #creo il controllore con le assunzioni per velocizzare l'ottimizazione
        #riformulo la matricedei jump
        cJumps=self.Jumps.copy()
        cProp=self.props.copy()
        for idx,val in enumerate(self.Jumps):
            p=self.props[idx]
            res=re.search(r"D", p, re.MULTILINE)
            if(res is not None):
                #print("infinite jump")
                fromIdx=np.where(np.array(val)==-1)
                toIdx=np.where(np.array(val)==1)
                for i in toIdx[0]:
                    if("_e" in self.names[i]):
                        #da qui devo risalire a ritroso e fare il merge dei jump
                        print("from",[self.names[i] for i in fromIdx[0]],"to",[self.names[i] for i in toIdx[0]])
                        #toSum=[idx]+np.where(np.array(self.Jumps)[:,fromIdx[0]]==1)[0].tolist()
                        for inState in np.where(np.array(self.Jumps)[:,fromIdx[0]]==1)[0].tolist():
                            toSum=[idx,inState]
                            toSum+=self._mergeInfJumps([inState])
                            print(toSum)
                            
                            #sommo le righe individuate e le elimino dalla matrice
                            #aggiorno anche le propensity
                            nProp=None
                            for j in toSum:
                                try:
                                    if self.Jumps[j] in cJumps:
                                        cJumps.remove(self.Jumps[j])
                                        
                                    #elimino la vecchia propensity   
                                    if(self.props[j] in cProp): 
                                        cProp.remove(self.props[j])
                                        
                                    #massaggio la nuova propensity
                                    pToRmv=self.props[j]
                                    isInfpToRmv=re.search(r"D",pToRmv, re.MULTILINE)
                                    if(isInfpToRmv is not None):
                                        probMatches = re.finditer(r"(P_[a-zA-Z]+)",pToRmv, re.MULTILINE | re.UNICODE)
                                        for matchNum, match in enumerate(probMatches, start=1):
                                            if(nProp is not None):
                                                nProp="%s*%s"%(match.group(),nProp)
                                            else:
                                                nProp=match.group()
                                    else:
                                        if(nProp is not None):
                                            nProp="%s*%s"%(self.props[j],nProp)
                                        else:
                                            nProp=self.props[j]
                                    
                                except:
                                    traceback.print_exc()
                                    raise ValueError()
            
                            cJumps.append(np.array(self.Jumps)[toSum,:].sum(axis=0).tolist())
                            cProp.append(nProp)
                            
            
        print(np.array(cJumps))
        
        tname = [t.name for t in self.lqn["task"]]
        mprops = []
        for p in cProp:
            npr = p
            for tn in tname:
                npr = npr.replace("NC[\"%s\"]" % (tn), "NC[%d]" % (tname.index(tn) + 1))
                npr = npr.replace("NT[\"%s\"]" % (tn), "NT[%d]" % (tname.index(tn) + 1))
            for vname in self.names:
                npr = npr.replace("MU[\"%s\"]" % (vname), "MU[%d]" % (self.names.index(vname) + 1))
            for vname in self.names:
                npr = npr.replace(vname, "X[%d-sum(toZero[1,1:%d])]" % (self.names.index(vname) + 1,self.names.index(vname) + 1))
            npr = npr.replace("D", "p.delta")
            mprops.append(npr)
        
        for p in mprops:
            print(p)
    
    def _mergeInfJumps(self,fromJ):  
        for idx in fromJ:
            toSum=[]
            #chiamo la ricorsione se serve
            p=self.props[idx]
            res=re.search(r"D", p, re.MULTILINE)
            if(res is not None and idx!=0):
                fromIdx=np.where(np.array(self.Jumps[idx])==-1) 
                toIdx=np.where(np.array(self.Jumps[idx])==1)
                for inState in np.where(np.array(self.Jumps)[:,fromIdx[0]]==1)[0].tolist():
                    toSum=[inState]
                    toSum+=self._mergeInfJumps([inState])
        return toSum
