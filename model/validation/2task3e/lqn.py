import numpy as np

class pyCRN(object):

	#states name
	#X(1)=XBrowse_2Address;
	#X(2)=XAddress_a;
	#X(3)=XAddress_2Home;
	#X(4)=XHome_a;
	#X(5)=XHome_e;
	#X(6)=XAddress_2Catalog;
	#X(7)=XCatalog_a;
	#X(8)=XCatalog_e;
	#X(9)=XAddress_2Cart;
	#X(10)=XCart_a;
	#X(11)=XCart_e;
	#X(12)=XAddress_e;
	#X(13)=XBrowse_browse;
	
	
	#task ordering
	#1=Client;
	#2=Router;
	#3=Front_end;
	
    
    name =  "2task3e"
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
        Rate=np.matrix([p["MU"][12]*X[12],
    			X[1]/(X[1])*p["delta"]*np.minimum(X[1],p["NT"][1]-(X[2]+X[5]+X[8]+X[11])),
    			X[3]/(X[3]+X[6]+X[9])*p["delta"]*np.minimum(X[3]+X[6]+X[9],p["NT"][2]-(X[4]+X[7]+X[10])),
    			X[2]/(X[2])*X[4]/(X[4]+X[7]+X[10])*np.minimum(X[4]+X[7]+X[10],p["NC"][2])*p["MU"][4],
    			X[6]/(X[3]+X[6]+X[9])*p["delta"]*np.minimum(X[3]+X[6]+X[9],p["NT"][2]-(X[4]+X[7]+X[10])),
    			X[5]/(X[5])*X[7]/(X[4]+X[7]+X[10])*np.minimum(X[4]+X[7]+X[10],p["NC"][2])*p["MU"][7],
    			X[9]/(X[3]+X[6]+X[9])*p["delta"]*np.minimum(X[3]+X[6]+X[9],p["NT"][2]-(X[4]+X[7]+X[10])),
    			X[8]/(X[8])*X[10]/(X[4]+X[7]+X[10])*np.minimum(X[4]+X[7]+X[10],p["NC"][2])*p["MU"][10],
    			X[0]/(X[0])*X[11]/(X[11])*np.minimum(X[11],p["NC"][1])*p["MU"][11],
    			])
    	Rate[np.isnan(Rate)]=0;
    	return Rate
    	
    