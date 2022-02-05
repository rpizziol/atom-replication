using Printf,CPLEX,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

#model = Model(CPLEX.Optimizer)
#model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMumps))
model = Model(Ipopt.Optimizer)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
#set_optimizer_attribute(model, "max_iter", 100000)
#set_optimizer_attribute(model, "tol", 10^-10)
#set_optimizer_attribute(model, "print_level", 0)

RT=[1.0000    0.0100  326.9900;
    1.0000    0.0100  781.9901]
RTm=[328.0000  327.0000  326.9900;
     783.0000  782.0000  781.9900]

npoints=size(RT,1)

@variable(model,P[i=1:3,j=1:3]>=0)
@variable(model,RTlqn[i=1:3,p=1:npoints]>=0)
@variable(model,E_abs[i=1:3,p=1:npoints]>=0)
@constraint(model,P.<=1)
@constraint(model,sum(P,dims=2).<=1)
#@constraint(model,[i=1:3],P[i,i]==0)


for p=1:npoints
    println(i," ",p)
    println(P[i,:]'*RT[p,:])
    for i=1:3
        @NLconstraint(model,RTlqn[i,p]==sum(P[i,j]*RTlqn[j,p] for j=1:3)+RT[p,i])
        @constraint(model,E_abs[i,p]>=RTlqn[i,p]-RTm[p,i])
        @constraint(model,E_abs[i,p]>=-RTlqn[i,p]+RTm[p,i])
    end
end


#@objective(model,Min, sum((RTlqn[i,p]-RTm[p,i])^2 for i=1:3 for p=1:1))
@objective(model,Min,sum(E_abs))
JuMP.optimize!(model)
