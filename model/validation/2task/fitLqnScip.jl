using JuMP, AmplNLWriter, Couenne_jll, Printf,Plots,MAT,ProgressBars,Statistics

function mmin(x,y)
    M=10^3
    Xmin=@variable(model)
    z=@variable(model,binary=true)
    @constraint(model,Xmin<=x)
    @constraint(model,Xmin<=y)
    @constraint(model,Xmin>=x-M*z)
    @constraint(model,Xmin>=y-M*(1-z))
    return Xmin
end

DATA = matread("/Users/emilio/git/atom-replication/model/validation/_3tierGPS/tier3GPS_ODE.mat")

nzIdz=DATA["Cli"].!=0

Cli=zeros(sum(nzIdz),1)
Tm=zeros(sum(nzIdz),size(DATA["Tm"],2))
RTm=zeros(sum(nzIdz),size(DATA["RTm"],2))
NC=zeros(sum(nzIdz),size(DATA["NC"],2))

for i=1:size(DATA["Cli"],1)
        if(DATA["Cli"][i]!=0)
                global Cli[i]=DATA["Cli"][i]
                global Tm[i,:]=DATA["Tm"][i,:]
                global RTm[i,:]=DATA["RTm"][i,:]
                global NC[i,:]=DATA["NC"][i,:]
        end
end

#      X0_E,X1_E,X2_E,X3_E
jump=[ -1   +1   +0   +0;
       -1   +0   +1   +0;
       -1   +0   +0   +1;
       +0   +0   +0   +0;
       +1   -1   +0   +0;
       +0   -1   +1   +0;
       +0   -1   +0   +1;
       +0   +0   +0   +0;
       +1   +0   -1   +0;
       +0   +1   -1   +0;
       +0   +0   -1   +1;
       +0   +0   +0   +0;
       +1   +0   +0   -1;
       +0   +1   +0   -1;
       +0   +0   +1   -1;
       +0   +0   +0   +0;
       ]

#npoints=size(RTm,1)
npoints=2
model = Model(() -> AmplNLWriter.Optimizer(Couenne_jll.amplexe))

mmu=1 ./minimum(DATA["RTm"],dims=1)

@variable(model,T[i=1:size(jump,1),j=1:npoints]>=0,start=0)
@variable(model,RTlqn[i=1:size(jump,2),p=1:npoints]>=0,start = 0) #cerco di far conservare anche il response time Steady, state
@variable(model,MU[i=1:size(jump,2)]<=1000)
@variable(model,X[i=1:size(jump,2),j=1:npoints]>=0)
@variable(model,P[i=1:size(jump,2),j=1:size(jump,2)]>=0)
@variable(model,P2[i=1:size(jump,2),j=1:size(jump,2)]>=0,start = 0)
@variable(model,E_abs[i=1:(1+size(jump,2)),j=1:npoints])
@variable(model,ERT_abs[i=1:size(jump,2),j=1:npoints])
@variable(model,RTs[i=1:size(jump,2),j=1:npoints],start = 0)
@variable(model,smin[p=1:npoints]>=0)

@constraint(model,sum(P,dims=2).==1)
@constraint(model,P2.<=1)
@constraint(model,P.<=1)
@constraint(model,[i=1:size(P2,1)],P2[i,i]==0)

@constraint(model,MU.>=mmu)
for idx=1:size(MU,2)
        set_start_value(MU[idx],mmu[idx])
end

Xu=DATA["RTm"].*DATA["Tm"];

for p=1:npoints

@NLconstraint(model,T[1,p]==P[1,2]*MU[1]*X[1,p])
@NLconstraint(model,T[2,p]==P[1,3]*MU[1]*X[1,p])
@NLconstraint(model,T[3,p]==P[1,4]*MU[1]*X[1,p])
@NLconstraint(model,T[4,p]==P[1,1]*MU[1]*X[1,p])

@constraint(model,smin[p]==mmin(X[2,p]+X[3,p]+X[4,p],NC[p,2]))

@NLconstraint(model,T[5,p]*(X[2,p]+X[3,p]+X[4,p])==X[2,p]*P[2,1]*MU[2]*smin[p])
@NLconstraint(model,T[6,p]*(X[2,p]+X[3,p]+X[4,p])==X[2,p]*P[2,3]*MU[2]*smin[p])
@NLconstraint(model,T[7,p]*(X[2,p]+X[3,p]+X[4,p])==X[2,p]*P[2,4]*MU[2]*smin[p])
@NLconstraint(model,T[8,p]*(X[2,p]+X[3,p]+X[4,p])==X[2,p]*P[2,2]*MU[2]*smin[p])

@NLconstraint(model,T[9,p]*(X[2,p]+X[3,p]+X[4,p])==X[3,p]*P[3,1]*MU[3]*smin[p])
@NLconstraint(model,T[10,p]*(X[2,p]+X[3,p]+X[4,p])==X[3,p]*P[3,2]*MU[3]*smin[p])
@NLconstraint(model,T[11,p]*(X[2,p]+X[3,p]+X[4,p])==X[3,p]*P[3,4]*MU[3]*smin[p])
@NLconstraint(model,T[12,p]*(X[2,p]+X[3,p]+X[4,p])==X[3,p]*P[3,3]*MU[3]*smin[p])

@NLconstraint(model,T[13,p]*(X[2,p]+X[3,p]+X[4,p])==X[4,p]*P[4,1]*MU[4]*smin[p])
@NLconstraint(model,T[14,p]*(X[2,p]+X[3,p]+X[4,p])==X[4,p]*P[4,2]*MU[4]*smin[p])
@NLconstraint(model,T[15,p]*(X[2,p]+X[3,p]+X[4,p])==X[4,p]*P[4,3]*MU[4]*smin[p])
@NLconstraint(model,T[16,p]*(X[2,p]+X[3,p]+X[4,p])==X[4,p]*P[4,4]*MU[4]*smin[p])

@constraint(model,jump'*T[:,p].==0)
# @constraint(model,jump'*T[:,p].<=10^-6)
# @constraint(model,jump'*T[:,p].>=-10^-6)



@NLconstraint(model,sum(T[i,p] for i in [1,2,3,4])*RTs[1,p]==X[1,p])
@NLconstraint(model,sum(T[i,p] for i in [5,6,7,8])*RTs[2,p]==X[2,p])
@NLconstraint(model,sum(T[i,p] for i in [9,10,11,12])*RTs[3,p]==X[3,p])
@NLconstraint(model,sum(T[i,p] for i in [13,14,15,16])*RTs[4,p]==X[4,p])

end

obj=[]
for p=1:npoints
        @constraints(model,begin
                E_abs[1,p]>=(sum(X[:,p])-Cli[p])
                E_abs[1,p]>=-(sum(X[:,p])-Cli[p])
                E_abs[2,p]>=(Tm[p,1]-sum(T[[1,2,3,4],p]))
                E_abs[2,p]>=-(Tm[p,1]-sum(T[[1,2,3,4],p]))
                E_abs[3,p]>=(Tm[p,2]-sum(T[[5,6,7,8],p]))
                E_abs[3,p]>=-(Tm[p,2]-sum(T[[5,6,7,8],p]))
                E_abs[4,p]>=(Tm[p,3]-sum(T[[9,10,11,12],p]))
                E_abs[4,p]>=-(Tm[p,3]-sum(T[[9,10,11,12],p]))
                E_abs[5,p]>=(Tm[p,4]-sum(T[[13,14,15,16],p]))
                E_abs[5,p]>=-(Tm[p,4]-sum(T[[13,14,15,16],p]))
        end)

        for i=1:size(jump,2)
            @NLconstraint(model,RTlqn[i,p]==sum(P2[i,j]*RTlqn[j,p] for j=1:size(jump,2))+RTs[i,p])
            #@constraint(model,RTlqn[i,p]==sum(P2[i,j]*DATA["RTm"][p,j] for j=1:size(jump,2))+RTs[i,p])
            @constraint(model,ERT_abs[i,p]>=RTlqn[i,p]-RTm[p,i])
            @constraint(model,ERT_abs[i,p]>=-RTlqn[i,p]+RTm[p,i])
        end
end


@objective(model,Min, sum(E_abs[i,p] for i=2:size(E_abs,1) for p=1:size(E_abs,2))+sum(ERT_abs[i,p] for i=1:size(ERT_abs,1) for p=1:size(E_abs,2)))
JuMP.optimize!(model)
