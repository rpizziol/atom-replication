'''
Created on 9 dic 2021

@author: emilio
'''

import traceback
from entity.Call import Call
from entity import SynchCall
import numpy as np
import json
from jinja2 import Environment, PackageLoader, select_autoescape


class LQN_CRN():
    
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
    
    def visit(self, act):
        # print("activity:"+act.name, "Entry:"+act.parentEntry.name, "Task:"+act.parentEntry.parentTask.name)
        
        idx = act.parentEntry.getActivities().index(act)
        sndName = None  # id dello stato locale da cui sottrarre
        lrcvName = None  # id dello stato da locale a cui aggiungere 
        rrcvName = None  # id dello stato remoto a cui aggiungere
        rsyncName = None  # id dello stato remoto con cui mi sincronizzo
        
        if(self.mapState):
            # la prima volta sviluppo lo stato
            if(act.parentEntry.getActivities().index(act) == 0 and not act.parentEntry.parentTask.ref):
                self.names.append("X%s_a" % (act.parentEntry.name))
            self.names.append("X%s_%s" % (act.parentEntry.name, act.name))
        
        # sviluppo i jump
        if(not act.parentEntry.parentTask.ref):
            if(idx == 0):
                sndName = "X%s_a" % (act.parentEntry.name)
                lrcvName = "X%s_%s" % (act.parentEntry.name, act.name)
            else:
                sndName = "X%s_%s" % (act.parentEntry.name, act.parentEntry.getActivities()[idx - 1].name)
                lrcvName = "X%s_%s" % (act.parentEntry.name, act.name)
                if(isinstance(act.parentEntry.getActivities()[idx - 1], SynchCall)):
                    rsyncName = "X%s_e" % (act.parentEntry.getActivities()[idx - 1].dest.name)
            
            if(isinstance(act, Call)):
                rrcvName = "X%s_a" % (act.dest.name)
        else:
            sndName = "X%s_%s" % (act.parentEntry.name, act.parentEntry.getActivities()[idx - 1].name)
            lrcvName = "X%s_%s" % (act.parentEntry.name, act.name)
            
            if(isinstance(act.parentEntry.getActivities()[idx - 1], SynchCall)):
                rsyncName = "X%s_e" % (act.parentEntry.getActivities()[idx - 1].dest.name)
            
            if(isinstance(act, Call)):
                rrcvName = "X%s_a" % (act.dest.name)
            
        if(self.genJump):
            jump = [0] * len(self.names)
            jump[self.names.index(sndName)] = -1
            jump[self.names.index(lrcvName)] = 1
            if(rrcvName is not None): 
                jump[self.names.index(rrcvName)] = 1
            if(rsyncName is not None):
                jump[self.names.index(rsyncName)] = -1
        
            self.Jumps.append(jump)
        
        
        if(self.genProp):
            # qui stabilisco la propensity di questa reazione
            prop = None
            if(not act.parentEntry.parentTask.ref):
                if(idx == 0):
                    # TBD propensity delle reazioni che si sincronizzano con un thread libero#
                    prop = "X%s_a/(%s)" % (act.parentEntry.name, "+".join(["X%s_a" % (e.name) for e in act.parentEntry.parentTask.entries]))
                    prop += "*D*min(%s,NT[\"%s\"]-%s)" % ("+".join(["X%s_a" % (e.name) for e in act.parentEntry.parentTask.entries]),
                                           act.parentEntry.parentTask.name,
                                           "+".join(["X%s_%s" % (a.parentEntry.name, a.name) for e in act.parentEntry.parentTask.entries for a in e.getActivities()]))
                else:
                    # TBD propensity delle reazioni che si sincronizzano con l'esecuzione nel server remoto#
                    # print("X%s_a"%act.parentEntry.getActivities()[idx-1].dest.name)
                    J = np.matrix(self.Jumps)
                    # print(J[:,self.names.index("X%s_a"%act.parentEntry.getActivities()[idx-1].dest.name)])
                    inIdx = np.where(J[:, self.names.index("X%s_a" % act.parentEntry.getActivities()[idx - 1].dest.name)] == 1)
                    
                    callingAct = []
                    for idx in inIdx[0]:
                        for n in np.where(J[idx,:] == 1)[1].tolist():
                            a = self.findAct(self.names[n].split("_")[-1])
                            if(isinstance(a, SynchCall)):
                                callingAct.append("X%s_%s" % (a.parentEntry.name, a.name))
                    
                    synA = self.findAct(rsyncName.split("_")[-1], rsyncName.split("_")[0][1:])
                    prop = "%s/(%s)*%s/(%s)*min(%s,NC[\"%s\"])*MU[\"%s\"]" % (sndName,
                                                                "+".join(callingAct),
                                                                rsyncName,
                                                                "+".join(["X%s_e" % (e.name) for e  in synA.parentEntry.parentTask.entries]),
                                                                rsyncName,
                                                                synA.parentEntry.parentTask.name
                                                                , rsyncName)
                    
            else:
                # TBD propensity delle reazioni del client#
                if(idx == 0):
                    prop = "MU[\"X%s_%s\"]*X%s_%s" % (act.parentEntry.name, act.parentEntry.getActivities()[-1].name,
                                                  act.parentEntry.name, act.parentEntry.getActivities()[-1].name)
                else:
                    # TBD propensity delle reazioni che si sincronizzano con l'esecuzione nel server remoto#
                    # print("X%s_a"%act.parentEntry.getActivities()[idx-1].dest.name)
                    J = np.matrix(self.Jumps)
                    # print(J[:,self.names.index("X%s_a"%act.parentEntry.getActivities()[idx-1].dest.name)])
                    inIdx = np.where(J[:, self.names.index("X%s_a" % act.parentEntry.getActivities()[idx - 1].dest.name)] == 1)
                    
                    callingAct = []
                    for idx in inIdx[0]:
                        for n in np.where(J[idx,:] == 1)[1].tolist():
                            a = self.findAct(self.names[n].split("_")[-1])
                            if(isinstance(a, SynchCall)):
                                callingAct.append("X%s_%s" % (a.parentEntry.name, a.name))
                    
                    synA = self.findAct(rsyncName.split("_")[-1], rsyncName.split("_")[0][1:])
                    prop = "%s/(%s)*%s/(%s)*min(%s,NC[\"%s\"])*MU[\"%s\"]" % (sndName,
                                                                "+".join(callingAct),
                                                                rsyncName,
                                                                "+".join(["X%s_e" % (e.name) for e  in synA.parentEntry.parentTask.entries]),
                                                                rsyncName,
                                                                synA.parentEntry.parentTask.name
                                                                , rsyncName)
            
            self.props.append(prop)
            
            # print(sndName, lrcvName, rrcvName,rsyncName)
            
        for a in act.getConAct():
            self.visit(a)   
            
    def findAct(self, aname, ename=None):
        # print(aname,ename)
        a_tgt = None
        for t in self.lqn["task"]:
            for e in t.entries:
                if(ename != None and ename != e.name):
                    continue
                else:
                    for a in e.getActivities():
                        if(a.name == aname):
                            a_tgt = a
                            break;
        
        if(a_tgt is None and aname != "a"):
            raise ValueError("activity %s not found " % (aname))
        
        return a_tgt
        
    def getCrn(self, lqn):
        self.lqn = lqn
        try:
            
            self.mapState = True
            
            # assumo che il primo task sia il reference task
            ref = self.lqn["task"][0].getEntries()[0]
            for a in ref.getActivities():
                self.visit(a)
                
            self.mapState = False
            self.genJump = True
            
            # assumo che il primo task sia il reference task
            ref = self.lqn["task"][0].getEntries()[0]
            for a in ref.getActivities():
                self.visit(a)
            
            self.genJump = False
            self.genProp = True
            
            # assumo che il primo task sia il reference task
            ref = self.lqn["task"][0].getEntries()[0]
            for a in ref.getActivities():
                self.visit(a)
            
        except:
            traceback.print_exc()
    
    def dumpToFile(self):
        crn = {"Jump":self.Jumps, "Prop":self.props, "State":self.names}
        y = json.dumps(crn)
        print(y)
    
    def toMatlab(self):
        env = Environment(
            loader=PackageLoader('trasducer', 'templates'),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=False,
            lstrip_blocks=False
            )
        
        tname=[t.name for t in self.lqn["task"]]
        
        mprops=[]
        for p in self.props:
            np=p
            for tn in tname:
                np=np.replace("NC[\"%s\"]"%(tn),"p.NC(%d)"%(tname.index(tn)+1))
                np=np.replace("NT[\"%s\"]"%(tn),"p.NT(%d)"%(tname.index(tn)+1))
                np=np.replace("D","p.delta")
            for vname in self.names:
                np=np.replace("MU[\"%s\"]"%(vname),"p.MU(%d)"%(self.names.index(vname)+1))
            for vname in self.names:
                np=np.replace(vname,"X(%d)"%(self.names.index(vname)+1))
            mprops.append(np)
        
        mat_tmpl = env.get_template('model-tpl.m')
        model=mat_tmpl.render(task=self.lqn["task"],name=self.lqn["name"],
              names=self.names,props=mprops,jumps=self.Jumps)
        mfid=open("../model/%s.m"%(self.lqn["name"]),"w+")
        mfid.write(model)
        mfid.close()
