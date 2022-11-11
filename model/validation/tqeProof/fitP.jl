using JuMP, CPLEX, MAT

model = Model(CPLEX.Optimizer)

DATA = matread("data.mat")

RTg=DATA["RTg"]
RTlg=DATA["RTlg"]

npoints=size(RTg,2)
#npoints=3
M=size(RTg,1)

@variable(model,P[i=1:M,j=1:M]>=0)
@variable(model,E_abs[i=1:M,p=1:npoints])


for p=1:npoints
    for i=1:M
        #@constraint(model,RTg[i,p]==sum(P[i,j]*RTg[j,p] for j=1:M)+RTlg[i,p])
        @constraint(model,E_abs[i,p]>=(sum(P[i,j]*RTg[j,p] for j=1:M)+RTlg[i,p]-RTg[i,p]))
        @constraint(model,E_abs[i,p]>=-(sum(P[i,j]*RTg[j,p] for j=1:M)+RTlg[i,p]-RTg[i,p]))
    end
end

@objective(model,Min,sum(E_abs))
JuMP.optimize!(model)
