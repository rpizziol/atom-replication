import numpy as np

class pyCRN(object):

	#states name
	#X(0)=XBrowse_2Address;
	#X(1)=XAddress_a;
	#X(2)=XAddress_2Home;
	#X(3)=XHome_a;
	#X(4)=XHome_e;
	#X(5)=XAddress_2Catalog;
	#X(6)=XCatalog_a;
	#X(7)=XCatalog_e;
	#X(8)=XAddress_2Cart;
	#X(9)=XCart_a;
	#X(10)=XCart_e;
	#X(11)=XAddress_e;
	#X(12)=XBrowse_browse;
	
	
	#task ordering
	#0=Client;
	#1=Router;
	#2=Front_end;
	
	
	name =  "twotask3e"
	stoich_matrix =  np.matrix([[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1],
	           [+0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0],
	           [+0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0],
	           [+0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0],
	           [+0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0],
	           [+0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0],
	           [+0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0],
	           [+0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0],
	           [-1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1],
	           ]);
	
	def prop_func(self,X,p):
		Rate=np.matrix([p["MU"][0,12]*X[12],
				X[1]/(X[1])*p["delta"]*np.minimum(X[1],p["NT"][0,1]-(X[2]+X[5]+X[8]+X[11])),
				X[3]/(X[3]+X[6]+X[9])*p["delta"]*np.minimum(X[3]+X[6]+X[9],p["NT"][0,2]-(X[4]+X[7]+X[10])),
				X[2]/(X[2])*X[4]/(X[4]+X[7]+X[10])*np.minimum(X[4]+X[7]+X[10],p["NC"][0,2])*p["MU"][0,4],
				X[6]/(X[3]+X[6]+X[9])*p["delta"]*np.minimum(X[3]+X[6]+X[9],p["NT"][0,2]-(X[4]+X[7]+X[10])),
				X[5]/(X[5])*X[7]/(X[4]+X[7]+X[10])*np.minimum(X[4]+X[7]+X[10],p["NC"][0,2])*p["MU"][0,7],
				X[9]/(X[3]+X[6]+X[9])*p["delta"]*np.minimum(X[3]+X[6]+X[9],p["NT"][0,2]-(X[4]+X[7]+X[10])),
				X[8]/(X[8])*X[10]/(X[4]+X[7]+X[10])*np.minimum(X[4]+X[7]+X[10],p["NC"][0,2])*p["MU"][0,10],
				X[0]/(X[0])*X[11]/(X[11])*np.minimum(X[11],p["NC"][0,1])*p["MU"][0,11],
				])
		Rate[np.isnan(Rate)]=0;
		return Rate.tolist()[0]