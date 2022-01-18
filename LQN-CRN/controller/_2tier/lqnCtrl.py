import numpy as np
import casadi
import matplotlib.pyplot as plt
import time

alfa=10**-5

def mmin(x,y):
	return -(-x-y+casadi.sqrt((-x+y)**2+alfa))/2.0

class _2tierCtrl(object):

	#states name
	#X(0)=XBrowse_2Address;
	#X(1)=XAddress_a;
	#X(2)=XAddress_2Home;
	#X(3)=XHome_a;
	#X(4)=XHome_e;
	#X(5)=XAddress_e;
	#X(6)=XBrowse_browse;
	
	
	#task ordering
	#0=Client;
	#1=Router;
	#2=Front_end;
	
	
	model = None
	stateVar = None
	NT = None
	NC = None
	initX = None
	H = None
	delta=10.0**4
	dt=0.5*10.0**-4
	
	name =  "_2tier"
	stoich_matrix =  np.matrix([[+1,  +1,  +0,  +0,  +0,  +0,  -1],
	          [+0,  -1,  +1,  +1,  +0,  +0,  +0],
	          [+0,  +0,  +0,  -1,  +1,  +0,  +0],
	          [+0,  +0,  -1,  +0,  -1,  +1,  +0],
	          [-1,  +0,  +0,  +0,  +0,  -1,  +1],
	          ]);
	
	def __init__(self,MU,H=50):
		self.H = H
		self.MU = MU
		self.model = self.model = casadi.Opti("conic")
		self.stateVar = self.model.variable(7,H+1);
		self.initX = self.model.parameter(7,1)
		self.tgt = self.model.parameter()
		self.NC = self.model.variable(1,3);
		self.NT = self.model.variable(1,3);
		self.Eabs = self.model.variable(1,H)
		self.buildOpt()
	
	def buildOpt(self):
		self.model.subject_to(self.stateVar[:,0]==self.initX);
		
		#self.model.subject_to(casadi.vec(self.stateVar)>=0)
		self.model.subject_to(self.model.bounded(0.0,self.NC[0,1:],1000))
		self.model.subject_to(self.Eabs>=0)
		self.model.subject_to(self.model.bounded(1,self.NT[0,1:],30000))
		

  # for h in range(self.H):
		    # self.model.subject_to(self.NT[0,1]>=self.stateVar[2,h]+self.stateVar[5,h])
		    # self.model.subject_to(self.NT[0,2]>=self.stateVar[4,h])
   # self.model.subject_to(self.NC[0,1]<=self.stateVar[5,h])
   # self.model.subject_to(self.NC[0,2]<=self.stateVar[4,h])
			
		
		for h in range(0,self.H):
			dxF=self.prop_func(self.stateVar[:,h],self.NT, self.NC, self.MU, self.delta,1)
			XhF=[]
			for i in range(self.stoich_matrix.T.shape[0]):
				xhf=0
				for j in range(self.stoich_matrix.T.shape[1]):
					xhf+=self.stoich_matrix.T[i,j]*dxF[j]
				XhF.append(xhf*self.dt+self.stateVar[i,h]);
			
			for s in range(self.stoich_matrix.shape[1]):
				self.model.subject_to(self.stateVar[s,h+1]==XhF[s])
		
		for h in range(0,self.H):
			self.model.subject_to(self.Eabs[0,h]>=self.stateVar[-1,h+1]-self.tgt)
			self.model.subject_to(self.Eabs[0,h]>=-(self.stateVar[-1,h+1]-self.tgt))
			
		optionsIPOPT = {'print_time':False, 'ipopt':{'print_level':0,"max_iter":5000}}
		optionsOSQP = {'print_time':False, 'osqp':{'verbose':False},"error_on_fail":False}
		#self.model.solver('ipopt',optionsIPOPT)
		self.model.solver('osqp', optionsOSQP)
	
	def Solve(self,X0,tgt,NC_old=None,NT_old=None):
		
		self.model.set_value(self.initX, X0)
		self.model.set_value(self.tgt,tgt)
		
		if(NC_old!=None):
			self.model.set_initial(self.NC, NC_old);
		
		self.model.minimize(casadi.sum2(self.Eabs))
		return self.model.solve()
		
	
	def prop_func(self,X,NT,NC,MU,delta,F):
		eps=10**-8
		Rate=[	MU[0,6]*X[6],
    # delta*casadi.fmin(X[1],NT[0,1]-(X[2]+X[5])),
    # delta*casadi.fmin(X[3],NT[0,2]-(X[4])),
    		    delta*X[1],
				delta*X[3],
			    casadi.fmin(X[4],NC[0,2])*MU[0,4],
			    casadi.fmin(X[5],NC[0,1])*MU[0,5]
       # NC[0,2]*MU[0,4],
       # NC[0,1]*MU[0,5],
				]
		return Rate

if __name__ == "__main__":
	from validation import matlabValidator
	matV = matlabValidator("../model/validation/%s/lqn.m"%("_2tier"))
	
	MU=np.matrix([10. for i in range(7)])		
	ctrl=_2tierCtrl(MU=MU)
	rep=1;
	dt=0.1
	TF=2*dt
	X0=[0,0,0,0,0,0,400]
	QL=[]
	optS=[]
	#0.3341
	NC=None
	NT=None
	tgt=100
	for i in range(200):
		st=time.time()
		sol=ctrl.Solve(X0=X0,tgt=tgt,NC_old=NC, NT_old=NT)
		NC=[sol.value(ctrl.NC[0,i]) for i in range(3)]
		#NT=[int(np.ceil(sol.value(ctrl.NT[0,i]))) for i in range(3)]
		NT=[np.sum(X0),np.sum(X0),np.sum(X0)]
		print(X0,NT,NC)
  # X=matV.solveModelIt(X0, MU.tolist()[0], NT, NC, dt=0.1,TF=TF, rep=rep)
  # X0=X[:,1].tolist()
		QL.append(X0)
		optS.append(NC[1:])
		X0=[sol.value(ctrl.stateVar[i,-1]) for i in range(7)]
	
	QL=np.matrix(QL)
	optS=np.matrix(optS)
	
	plt.figure()
	plt.plot(QL[:,-1])
	plt.axhline(tgt)
	
	plt.figure()
	plt.plot(optS[:,0],label="NC1")
	plt.plot(optS[:,1],label="NC2")
	plt.legend()
	
	plt.show()