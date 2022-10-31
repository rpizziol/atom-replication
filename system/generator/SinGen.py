'''
Created on 9 mar 2022

@author: emilio
'''
from generator import Generator
import numpy as np
from matplotlib import pyplot as plt

class SinGen(Generator):
    '''
    classdocs
    '''
    
    period=None
    shift=None
    mod=None
    

    def __init__(self,period,shift,mod):
        self.period=period
        self.shift=shift
        self.mod=mod
    
    def getUser(self, t):
        return np.sin(t/(self.period/(2*np.pi)))*self.mod+self.shift


if __name__ == '__main__':
    
    period=200
    shift=1520
    mod=1500
    step=5
    sgen=SinGen(period,shift,mod)
    users=[]
    for t in range(0, period+step,step):
        users.append(sgen.getUser(t))
        
    plt.figure()
    plt.step(range(0, period+step,step),users)
    plt.show()
    
