import numpy as np
import casadi

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
	dt=10**-4
	
	name =  "_2tier"
	stoich_matrix =  np.matrix([[+1,  +1,  +0,  +0,  +0,  +0,  -1],
	          [+0,  -1,  +1,  +1,  +0,  +0,  +0],
	          [+0,  +0,  +0,  -1,  +1,  +0,  +0],
	          [+0,  +0,  -1,  +0,  -1,  +1,  +0],
	          [-1,  +0,  +0,  +0,  +0,  -1,  +1],
	          ]);
	
	def __init__(self,MU,H=5):
		self.H = H
		self.MU = MU
		self.model = self.model = casadi.Opti()
		self.stateVar = self.model.variable(7,H+1);
		self.initX = self.model.parameter(7,1)
		self.NC = self.model.variable(1,3);
		self.NT = self.model.variable(1,3);
		self.buildOpt()
	
	def buildOpt(self):
		self.model.subject_to(self.stateVar[:,0]==self.initX);
		
		self.model.subject_to(casadi.vec(self.stateVar)>=0)
		self.model.subject_to(self.model.bounded(0,self.NC,1000))
		self.model.subject_to(self.model.bounded(0,self.NT,1000))
		
		for h in range(0,self.H):
			dxF=self.prop_func(self.stateVar[:,h],self.NT, self.NC, self.MU, self.delta,1)
			XhF=[]
			for i in range(self.stoich_matrix.T.shape[0]):
				xhf=0
				for j in range(self.stoich_matrix.T.shape[1]):
					xhf+=self.stoich_matrix.T[i,j]*dxF[j]*self.dt/2
				XhF.append(xhf+self.stateVar[i,h]);
			
			dxF1=self.prop_func(XhF,self.NT, self.NC, self.MU, self.delta,0)
			XhF1=[]
			for i in range(self.stoich_matrix.T.shape[0]):
				xhf1=0
				for j in range(self.stoich_matrix.T.shape[1]):
					xhf1+=self.stoich_matrix.T[i,j]*dxF1[j]*self.dt
				XhF1.append(xhf+XhF[i]);
				
			dxF2=self.prop_func(XhF1,self.NT, self.NC, self.MU, self.delta,1)
			XhF2=[]
			for i in range(self.stoich_matrix.T.shape[0]):
				xhf2=0
				for j in range(self.stoich_matrix.T.shape[1]):
					xhf2+=self.stoich_matrix.T[i,j]*dxF2[j]*self.dt/2
				XhF2.append(xhf+XhF1[i]);
			
		for i in range(self.stoich_matrix.shape[1]):
			self.model.subject_to(self.stateVar[i,h+1]==XhF2[i])
			
		#optionsIPOPT={'print_time':False,'ipopt':{'print_level':0}}
		self.model.solver('ipopt',{})  
	
	def Solve(self,X0,MU,NC_old=None,NT_old=None):
		
		self.model.set_value(self.initX, X0)
			
		obj=0
		for h in range(1,self.H+1):
			obj+=(self.stateVar[-1,h]*MU[0,-1]-10)**2
		
		self.model.minimize(obj)
		self.model.solve()
		
	
	def prop_func(self,X,NT,NC,MU,delta,F):
		Rate=[(1-F)*MU[0,6]*X[6],
				X[1]/(X[1])*F*delta*casadi.fmin(X[1],NT[0,1]-(X[2]+X[5])),
				X[3]/(X[3])*F*delta*casadi.fmin(X[3],NT[0,2]-(X[4])),
				(1-F)*X[2]/(X[2])*X[4]/(X[4])*casadi.fmin(X[4],NC[0,2])*MU[0,4],
				(1-F)*X[0]/(X[0])*X[5]/(X[5])*casadi.fmin(X[5],NC[0,1])*MU[0,5],
				]
		return Rate

if __name__ == "__main__":
	ctrl=_2tierCtrl(MU=np.matrix([0 for i in range(7)]))
	print(ctrl.stateVar[:,0])