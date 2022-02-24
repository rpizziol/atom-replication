using SCIP,Printf,CPLEX,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

function mmin(x,y)
     return  ((x+y) - abs(x-y))/2
end

delta=10.0^5

DATA = matread("tier3.mat")

model = Model(SCIP.Optimizer)
# MOI.set(optimizer, SCIP.Param("display/verblevel"), 0)
# MOI.set(optimizer, SCIP.Param("limits/gap"), 0.05)

#     X0_A,X0_E,X1_A,X1_E,X2_A,X2_E
jump=[  -1   +1   +0   +0   +0   +0;
        +0   -1   +1   +0   +0   +0;
        +0   -1   +0   +0   +1   +0;
        +1   -1   +0   +0   +0   +0;
        +0   +0   -1   +1   +0   +0;
        +0   +0   +0   -1   +1   +0;
        +1   +0   +0   -1   +0   +0;
        +0   +0   +1   -1   +0   +0;
        +0   +0   +0   +0   -1   +1;
        +1   +0   +0   +0   +0   -1;
        +0   +0   +1   +0   +0   -1;
        +0   +0   +0   +0   +1   -1;
        ]


#npoints=size(DATA["RTm"],1)
npoints=2

@variable(model,T[i=1:size(jump,1),j=1:npoints]>=0,start=10^-5)
@variable(model,RTlqn[i=1:Int(size(jump,2)/2),p=1:npoints]>=10^-10,start = 0) #cerco di far conservare anche il response time Steady, state
@variable(model,MU[i=1:Int(size(jump,2)/2)]>=10^-5,start =10^-5)
@variable(model,X[i=1:size(jump,2),j=1:npoints]>=0,start = 0)
@variable(model,P[i=1:Int(size(jump,2)/2),j=1:Int(size(jump,2)/2)]>=0,start = 0)


@variable(model,P2[i=1:Int(size(jump,2)/2),j=1:Int(size(jump,2)/2)]>=0,start = 0)
@variable(model,E_abs[i=1:(1+floor(Int, size(jump,2)/2)),j=1:npoints]>=0,start = 0)
@variable(model,ERT_abs[i=1:floor(Int, size(jump,2)/2),j=1:npoints]>=0,start = 0)
@variable(model,RTs[i=1:floor(Int, size(jump,2)/2),j=1:npoints]>=0,start = 0)

@constraint(model,sum(P,dims=2).==1)
@constraint(model,P2.<=1)
@constraint(model,P.<=1)
@constraint(model,[i=1:size(P2,1)],P2[i,i]==0)

for p=1:npoints
@constraint(model,T[1,p]==delta*X[1,p])
@NLconstraint(model,T[2,p]==P[1,2]*MU[1]*X[2,p])
@NLconstraint(model,T[3,p]==P[1,3]*MU[1]*X[2,p])
@NLconstraint(model,T[4,p]==P[1,1]*MU[1]*X[2,p])

@constraint(model,T[5,p]==delta*X[3,p])
@NLconstraint(model,T[6,p]==P[2,3]*MU[2]*(mmin(X[4,p],DATA["NC"][p,2])))
@NLconstraint(model,T[7,p]==P[2,1]*MU[2]*(mmin(X[4,p],DATA["NC"][p,2])))
@NLconstraint(model,T[8,p]==P[2,2]*MU[2]*(mmin(X[4,p],DATA["NC"][p,2])))


@constraint(model,T[9,p]==delta*X[5,p])
@NLconstraint(model,T[10,p]==P[3,1]*MU[3]*(mmin(X[6,p],DATA["NC"][p,3])))
@NLconstraint(model,T[11,p]==P[3,2]*MU[3]*(mmin(X[6,p],DATA["NC"][p,3])))
@NLconstraint(model,T[12,p]==P[3,3]*MU[3]*(mmin(X[6,p],DATA["NC"][p,3])))


@constraint(model,jump'*T[:,p].<=10^-10)
@constraint(model,jump'*T[:,p].>=-10^-10)

@NLconstraint(model,sum(T[i,p] for i in [2,3,4])*RTs[1,p]==X[2,p])
@NLconstraint(model,sum(T[i,p] for i in [6,7,8])*RTs[2,p]==X[4,p])
@NLconstraint(model,sum(T[i,p] for i in [10,11,12])*RTs[3,p]==X[6,p])
end

obj=[]
for p=1:npoints
        @constraints(model,begin
                E_abs[1,p]>=(sum(X[:,p])-DATA["Cli"][p])
                E_abs[1,p]>=-(sum(X[:,p])-DATA["Cli"][p])
                E_abs[2,p]>=(DATA["Tm"][p,1]-sum(T[[2,3,4],p]))
                E_abs[2,p]>=-(DATA["Tm"][p,1]-sum(T[[2,3,4],p]))
                E_abs[3,p]>=(DATA["Tm"][p,2]-sum(T[[6,7,8],p]))
                E_abs[3,p]>=-(DATA["Tm"][p,2]-sum(T[[6,7,8],p]))
                E_abs[4,p]>=(DATA["Tm"][p,3]-sum(T[[10,11,12],p]))
                E_abs[4,p]>=-(DATA["Tm"][p,3]-sum(T[[10,11,12],p]))
        end)

        for i=1:Int(size(jump,2)/2)
            @NLconstraint(model,RTlqn[i,p]==sum(P2[i,j]*RTlqn[j,p] for j=1:Int(size(jump,2)/2))+RTs[i,p])
            #@constraint(model,RTlqn[i,p]==sum(P2[i,j]*DATA["RTm"][p,j] for j=1:Int(size(jump,2)/2))+RTs[i,p])
            @constraint(model,ERT_abs[i,p]>=RTlqn[i,p]-DATA["RTm"][p,i])
            @constraint(model,ERT_abs[i,p]>=-RTlqn[i,p]+DATA["RTm"][p,i])
        end
end

@objective(model,Min, sum(E_abs)+sum(ERT_abs))
JuMP.optimize!(model)
