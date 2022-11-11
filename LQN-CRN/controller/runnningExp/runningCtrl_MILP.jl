using JuMP,SCIP, Bonmin_jll, AmplNLWriter

function min_(model,x1,x2,M)
	D=@variable(model,binary = true)
	Y=@variable(model,lower_bound = 0)

	@constraint(model,Y<=x1)
	@constraint(model,Y<=x2)
	@constraint(model,Y>=x1-M*(D))
	@constraint(model,Y>=x2-M*(1-D))
	return Y
end

#model = Model(() -> AmplNLWriter.Optimizer(Couenne_jll.amplexe))
model = Model(() -> AmplNLWriter.Optimizer(Bonmin_jll.amplexe))
#model = Model(SCIP.Optimizer)
M=10^3

jump=[+1  +1  +0  +0  -1;
      +0  -1  +1  +0  +0;
      +0  -1  +0  +1  +0;
      -1  +0  -1  +0  +1;
      -1  +0  +0  -1  +1;
    ];

MU=ones(1,size(jump,2))*-1

MU[3]=1.0 #c1
MU[4]=1.0 #c2
MU[5]=1.0 #Browse

P_c1=0.5;
P_c2=0.5;
delta=10^5
maxNC=1000
maxNT=1000

@variable(model,T[i=1:size(jump,1)]>=0)
@variable(model,X[i=1:size(jump,2)]>=0)
@variable(model,C == 0, Param())
@variable(model,NC>=0)
@variable(model,NT>=0,Int)
@variable(model,GPS>=0)
@variable(model,Tms>=0)

@constraint(model,sum(X[i] for i=2:size(jump,2))==C)
#@constraint(model,X[1]==X[2]+X[3]+X[4])

#--------rate
@constraint(model,Tms==delta*min_(model,NT-(X[3]+X[4]),X[2],M))
@constraint(model,GPS==min_(model,(X[3]+X[4]),NC,M))

@constraint(model,T[1]==MU[5]*X[5])
@NLconstraint(model,T[2]==P_c1*Tms)
@NLconstraint(model,T[3]==P_c2*Tms)
@NLconstraint(model,T[4]==X[3]/(X[3]+X[4])*MU[3]*GPS)
@NLconstraint(model,T[5]==X[4]/(X[3]+X[4])*MU[4]*GPS)

#-----response time constraints

@constraint(model,jump'*T.==0)
@constraint(model,NC.<=maxNC)
@constraint(model,NT.<=maxNT)

#--------------
npoint=20
NCopt=zeros(1,npoint)
NTopt=zeros(1,npoint)
stimeOpt=zeros(1,npoint)
clients=LinRange(1,100, npoint);

for i=1:size(clients,1)
    global w=round(clients[i])
    set_value(C,w)

    @objective(model,Max,0.5*(T[1])/(MU[5]*w)-0.5*(NC+NT)/(maxNC+maxNT))
    global stimes=@elapsed JuMP.optimize!(model)
    global status=termination_status(model)
    if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED && status!=MOI.OPTIMAL)
        error(status)
    end

    #RTv=[value(X[1]+X[5])/value(T[1]),value(X[3])/value(T[4]),value(X[4])/value(T[5])];
    #Tv=[value(T[1]),value(T[4]),value(T[5])]

    NCopt[i]=value(NC)
    NTopt[i]=value(NT)
    stimeOpt[i]=stimes
end

matwrite("/Users/emilio/git/atom-replication/model/validation/runExp/reMINL.mat", Dict(
	"NC_opt" => NCopt,
	"NT_opt" => NTopt,
	"Clients" =>  collect(clients),
	"rtime_opt" => stimeOpt
);)
