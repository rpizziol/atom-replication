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
	
	name =  "_2tier"
	stoich_matrix =  np.matrix([[+1,  +1,  +0,  +0,  +0,  +0,  -1],
	          [+0,  -1,  +1,  +1,  +0,  +0,  +0],
	          [+0,  +0,  +0,  -1,  +1,  +0,  +0],
	          [+0,  +0,  -1,  +0,  -1,  +1,  +0],
	          [-1,  +0,  +0,  +0,  +0,  -1,  +1],
	          ]);
	
	def __init__(self,H=5):
		self.H = H
		self.model = self.model = casadi.Opti()
		self.stateVar = self.model.variable(7,H);
		self.initX = self.model.parameter(7,1)
		self.NC = self.model.variable(3,1);
		self.NT = self.model.variable(3,1);
		self.buildOpt()
	
	def buildOpt(self):
		pass
	
	def Solve(self,X0,MU,NC_old=None,NT_old=None):
		pass
		
	
	#def prop_func(self,X,p):
	#	Rate=np.matrix([p["MU"][0,6]*X[6],
	#			X[1]/(X[1])*p["delta"]*np.minimum(X[1],p["NT"][0,1]-(X[2]+X[5])),
	#			X[3]/(X[3])*p["delta"]*np.minimum(X[3],p["NT"][0,2]-(X[4])),
	#			X[2]/(X[2])*X[4]/(X[4])*np.minimum(X[4],p["NC"][0,2])*p["MU"][0,4],
	#			X[0]/(X[0])*X[5]/(X[5])*np.minimum(X[5],p["NC"][0,1])*p["MU"][0,5],
	#			])
	#	Rate[np.isnan(Rate)]=0;
	#	return Rate.tolist()[0]