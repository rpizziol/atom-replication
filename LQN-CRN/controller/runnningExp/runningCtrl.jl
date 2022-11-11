using Printf,Ipopt,JuMP,MAT,ParameterJuMP,Statistics

wdir=pwd()

#model = Model(()->MadNLP.Optimizer(print_level=MadNLP.INFO))
model = Model(Ipopt.Optimizer)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
#set_optimizer_attribute(model, "max_iter", 10000)
#set_optimizer_attribute(model, "tol", 10^-10)
set_optimizer_attribute(model, "hessian_approximation", "limited-memory")
#set_optimizer_attribute(model, "print_level", 0)

jump=[+1  +1  +0  +0  -1;
    +0  -1  +1  +0  +0;
    +0  -1  +0  +1  +0;
    -1  +0  -1  +0  +1;
    -1  +0  +0  -1  +1;
    ];


P_c1=0.5;
P_c2=0.5;
delta=10^5
alpha=10^-3
maxNC=1000
maxNT=1000

MU=ones(1,size(jump,2))*-1

MU[3]=1.0 #c1
MU[4]=1.0 #c2
MU[5]=1.0 #Browse

@variable(model,T[i=1:size(jump,1)]>=0)
@variable(model,X[i=1:size(jump,2)]>=0)
@variable(model,C == 0, Param())
@variable(model,NC>=0)
@variable(model,NT>=0)
@variable(model,GPS>=0)
#@variable(model,Tms>=0)

@constraint(model,sum(X[i] for i=2:size(jump,2))==C)
#@constraint(model,X[1]==X[2]+X[3]+X[4])


@constraint(model,jump'*T.==0)
@constraint(model,NC.<=maxNC)
@constraint(model,NT.<=maxNT)



#--------rate
#-(-a-b+sqrt((-a+b)^2+10^-2))/2;
Tms=@NLexpression(model,delta*-(-(NT-(X[3]+X[4]))-X[2]+sqrt((-(NT-(X[3]+X[4]))+X[2])^2+alpha))/2)
#GPS=@NLexpression(model,-(-(X[3]+X[4])-NC+sqrt((-(X[3]+X[4])+NC)^2+alpha))/2)

#@constraint(model,Tms<=NT-(X[3]+X[4]))
#@constraint(model,Tms<=X[2])

@constraint(model,GPS<=(X[3]+X[4]))
@constraint(model,GPS<=NC)

@constraint(model,T[1]==MU[5]*X[5])
@NLconstraint(model,T[2]==P_c1*Tms)
@NLconstraint(model,T[3]==P_c2*Tms)
@NLconstraint(model,T[4]==X[3]/(X[3]+X[4])*MU[3]*GPS)
@NLconstraint(model,T[5]==X[4]/(X[3]+X[4])*MU[4]*GPS)

#-----response time constraints
@constraint(model,(X[1]+X[5])<=(MU[5]+P_c1*MU[3]+P_c2*MU[4])*1.02*T[1])
@constraint(model,(X[3])<=MU[3]*1.02*T[4])
@constraint(model,(X[4])<=MU[4]*1.02*T[5])

#--------------
npoint=20
NCopt=zeros(1,npoint)
NTopt=zeros(1,npoint)
stimeOpt=zeros(1,npoint)
clients=LinRange(1,100, npoint);

#clients=[10]

for i=1:size(clients,1)
    global w=round(clients[i])
    set_value(C,w)

    @objective(model,Max,0.5*(T[1])/(MU[5]*w)-0.5*(NC+NT)/(maxNC+maxNT))
    global stimes=@elapsed JuMP.optimize!(model)
    global status=termination_status(model)
    if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
        error(status)
    end

    #RTv=[value(X[1]+X[5])/value(T[1]),value(X[3])/value(T[4]),value(X[4])/value(T[5])];
    #Tv=[value(T[1]),value(T[4]),value(T[5])]

    NCopt[i]=value(NC)
    NTopt[i]=value(NT)
    stimeOpt[i]=stimes
end

matwrite("/Users/emilio/git/atom-replication/model/validation/runExp/re.mat", Dict(
	"NC_opt" => NCopt,
	"NT_opt" => NTopt,
	"Clients" =>  collect(clients),
	"rtime_opt" => stimeOpt
);)
