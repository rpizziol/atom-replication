using Printf,CPLEX,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

#model = Model(CPLEX.Optimizer)
#model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMumps))
model = Model(Ipopt.Optimizer)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
#set_optimizer_attribute(model, "max_iter", 100000)
#set_optimizer_attribute(model, "tol", 10^-10)
#set_optimizer_attribute(model, "print_level", 0)

RT=[1.0000    0.0100   465.9900;
    1.0000    0.0100   758.9900;
    1.0000    0.0100   927.9900;
    1.0000    0.0100   655.9900;
    1.0000    5.5080    1.0000;
    
    ]

RTm=[467.0000  466.0000  465.9900;
    760.0000  759.0000  758.9900;
    929.0000  928.0000  927.9900;
    657.0000  656.0000  655.9900;
     7.5100    6.5100    1.0000;
     2.0100    1.0100    1.0000;
    ]

npoints=size(RT,1)

@variable(model,P[i=1:3,j=1:3]>=0)
@variable(model,RTlqn[i=1:3,p=1:npoints]>=0)
@variable(model,E_abs[i=1:3,p=1:npoints]>=0)
@constraint(model,P.<=1)
@constraint(model,sum(P,dims=2).<=2)
#@constraint(model,[i=1:3],P[i,i]==0)


for p=1:npoints
    for i=1:3
        #@NLconstraint(model,RTlqn[i,p]==sum(P[i,j]*RTlqn[j,p] for j=1:3)+RT[p,i])
        @NLconstraint(model,RTlqn[i,p]==sum(P[i,j]*RT[p,j] for j=1:3))
        @constraint(model,E_abs[i,p]>=RTlqn[i,p]-RTm[p,i])
        @constraint(model,E_abs[i,p]>=-RTlqn[i,p]+RTm[p,i])
    end
end


#@objective(model,Min, sum((RTlqn[i,p]-RTm[p,i])^2 for i=1:3 for p=1:1))
@objective(model,Min,sum(E_abs))
JuMP.optimize!(model)
