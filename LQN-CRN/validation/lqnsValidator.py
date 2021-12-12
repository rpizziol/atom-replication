'''
Created on 11 dic 2021

@author: emilio
'''

from pathlib import Path
import subprocess
import numpy as np
import scipy.stats as st
from validation import Validator
from jinja2 import Environment, PackageLoader, select_autoescape, FileSystemLoader
import re


class lqnsValidator(Validator):
    
    modelFilePath = None
    modelDirPath = None
    jenv = None

    def __init__(self, modelPathStr):
        super().__init__()
        self.modelFilePath = Path(modelPathStr)
        if(self.modelFilePath.exists()):
            self.modelDirPath = self.modelFilePath.parents[0]
        else:
            raise ValueError("File %s not found" % (modelPathStr))
        templateLoader = FileSystemLoader(searchpath=self.modelDirPath.absolute())
        self.jenv = Environment(loader=templateLoader,autoescape=select_autoescape(['html', 'xml']))
        
    def solveModel(self, X0=None, MU=None, NT=None, NC=None, TF=None, rep=None, dt=None):
        mat_tmpl = self.jenv.get_template('lqn_t.lqn')
        model = mat_tmpl.render(nc=NC,nt=NT,nuser=X0)
        
        lqnf=open(self.modelDirPath/"lqn.lqn","w+")
        lqnf.write(model)
        lqnf.close()
        
        try:
            subprocess.check_call(["lqsim",self.modelDirPath/"lqn.lqn"])
        except:
            subprocess.check_call(["lqns",self.modelDirPath/"lqn.lqn"])
            
            
        return self.getRes()
    
    def getRes(self):
        out=open(self.modelDirPath/"lqn.out","r")
        res=[]
        while True: 
            # Get next line from file
            line = out.readline()
            if("Throughputs and utilizations" in line):
                out.readline()
                out.readline()
                line=out.readline()
                while(line!="\n"):
                    line=re.sub(r'\s+'," ", line)
                    info=line.split(" ")
                    task=info[0]
                    entry=info[1]
                    trg=float(info[2])
                    res.append({"task":task,"entry":entry,"trg":trg})
                    line=out.readline()
                break
            
            if not line:
                break
        out.close()
        
        return res
        
    def getResult(self):
        pass
    

if __name__ == '__main__':
    mv = lqnsValidator("../model/validation/single_task/lqn_t.lqn")
    
    res=mv.solveModel(X0=100,NT=[-1,1],NC=[-1,1])
    print(res)
