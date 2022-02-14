using Printf,CPLEX,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

delta=10.0^5

#model = Model(CPLEX.Optimizer)
#model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMumps))
model = Model(Ipopt.Optimizer)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
set_optimizer_attribute(model, "max_iter", 100000)
#set_optimizer_attribute(model, "tol", 10^-10)
#set_optimizer_attribute(model, "print_level", 0)

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

NC=[  100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;
      100000 1.0 1.0;]

Xm = [   0    1.0000    0.0000  569.9900    0.0000    0.0100;
         0    1.0000    0.0000  344.9900    0.0000    0.0100;
         0    1.0000    0.0000  745.9900    0.0000    0.0100;
         0    1.0000    0.0000  798.9900    0.0000    0.0100;
         0    1.0000    0.0000  171.9900    0.0000    0.0100;
         0    1.0000    0.0000  297.9900    0.0000    0.0100;
         0    1.0000    0.0000  281.9900    0.0000    0.0100;
         0    1.0000    0.0000  660.9900    0.0000    0.0100;
         0    1.0000    0.0000  751.9900    0.0000    0.0100;
         0    1.0000    0.0000  849.9900    0.0000    0.0100;]


RT = [  571.0000  569.9900    0.0100;
        346.0000  344.9900    0.0100;
        747.0000  745.9900    0.0100;
        800.0000  798.9900    0.0100;
        173.0000  171.9900    0.0100;
        299.0000  297.9900    0.0100;
        283.0000  281.9900    0.0100;
        662.0000  660.9900    0.0100;
        753.0000  751.9900    0.0100;
        851.0000  849.9900    0.0100;];

T =[]

npoints=size(Xm,1)

#f(x::T, y::T) where {T<:Real} = -(-x-0+((-x+0)^2+10^-100)^(1.0/2))/2.0
f(x::T) where {T<:Real} = -(-x+((-x)^2+10^-100)^(1.0/2))/2.0
function ∇f(g::AbstractVector{T}, x::T, y::T) where {T<:Real}
    g[1] = 1/2 - (2*x - 2*y)/(4*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2))
    g[2] = (2*x - 2*y)/(4*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2)) + 1/2
    return
end
register(model, :min_, 1, f, autodiff=true) #∇f)

@variable(model,T[i=1:size(jump,1),j=1:npoints]>=10^-8,start = 1)
@variable(model,Ts[i=1:Int(size(jump,2)/2),p=1:npoints]>=0)
@variable(model,RTlqn[i=1:Int(size(jump,2)/2),p=1:npoints]>=0,start = 0) #cerco di far conservare anche il response time Steady, state
@variable(model,MU[i=1:Int(size(jump,2)/2)]>=0)
#MU=[1.0000083000117839 100.08319844924557 0.9999999999997733]
@variable(model,X[i=1:size(jump,2),j=1:npoints]>=0,start = 1)
@variable(model,P[i=1:Int(size(jump,2)/2),j=1:Int(size(jump,2)/2)]>=0)

# Prnd=rand(size(P,1),size(P,1))
# # Prnd=[1 0 0;
# #       0 1 0;
# #       0 0 1]
# Prnd=Prnd./sum(Prnd,dims=2)
# for i=1:size(P,1)
#     for j=1:size(P,1)
#         set_start_value(P[i,j],Prnd[i,j])
#     end
# end

@variable(model,P2[i=1:Int(size(jump,2)/2),j=1:Int(size(jump,2)/2)]>=0)
# P2=[0 1 0;
#     0 0 1;
#     0 0 0]


# for i=1:size(P2,1)
#     for j=1:size(P2,1)
#         #set_start_value(P2[i,j],Prnd[i,j])
#     end
# end

@variable(model,E_abs[i=1:size(jump,2)+floor(Int, size(jump,2)/2),j=1:npoints]>=0,start = 0)
@variable(model,ERT_abs[i=1:floor(Int, size(jump,2)/2),j=1:npoints]>=0,start = 0)
@variable(model,RTs[i=1:floor(Int, size(jump,2)/2),j=1:npoints]>=0,start = 0)

@constraint(model,sum(P,dims=2).==1)
#@constraint(model,sum(P2,dims=2).<=1)
@constraint(model,P2.<=1)
@constraint(model,P.<=1)
@constraint(model,[i=1:size(P2,1)],P2[i,i]==0)

for p=1:npoints
@constraint(model,T[1,p]==delta*X[1,p])
@NLconstraint(model,T[2,p]==P[1,2]*MU[1]*X[2,p])
@NLconstraint(model,T[3,p]==P[1,3]*MU[1]*X[2,p])
@NLconstraint(model,T[4,p]==P[1,1]*MU[1]*X[2,p])

@constraint(model,T[5,p]==delta*X[3,p])
@NLconstraint(model,T[6,p]==P[2,3]*MU[2]*(min_(X[4,p]-NC[p,2])+NC[p,2]))
@NLconstraint(model,T[7,p]==P[2,1]*MU[2]*(min_(X[4,p]-NC[p,2])+NC[p,2]))
@NLconstraint(model,T[8,p]==P[2,2]*MU[2]*(min_(X[4,p]-NC[p,2])+NC[p,2]))


@constraint(model,T[9,p]==delta*X[5,p])
@NLconstraint(model,T[10,p]==P[3,1]*MU[3]*(min_(X[6,p]-NC[p,3])+NC[p,3]))
@NLconstraint(model,T[11,p]==P[3,2]*MU[3]*(min_(X[6,p]-NC[p,3])+NC[p,3]))
@NLconstraint(model,T[12,p]==P[3,3]*MU[3]*(min_(X[6,p]-NC[p,3])+NC[p,3]))

@constraint(model,jump'*T[:,p].==0)

@NLconstraint(model,sum(T[i,p] for i in [2,3,4])*RTs[1,p]==X[2,p])
@NLconstraint(model,sum(T[i,p] for i in [6,7,8])*RTs[2,p]==X[4,p])
@NLconstraint(model,sum(T[i,p] for i in [10,11,12])*RTs[3,p]==X[6,p])

end

#qui i contraint nel caso di una sola misurazione
#@constraint(model,MU[1]==1.0)
@constraint(model,P[1,1]==0)



obj=[]
for p=1:npoints
        @constraint(model,sum(X[:,p])==sum(Xm[p,:]))
        @constraints(model,begin
                E_abs[1,p]>=(X[1,p]-Xm[p,1])
                E_abs[1,p]>=-(X[1,p]-Xm[p,1])
                E_abs[2,p]>=X[2,p]-Xm[p,2]
                E_abs[2,p]>=-(X[2,p]-Xm[p,2])
                E_abs[3,p]>=X[3,p]-Xm[p,3]
                E_abs[3,p]>=-(X[3,p]-Xm[p,3])
                E_abs[4,p]>=(X[4,p]-Xm[p,4])
                E_abs[4,p]>=-(X[4,p]-Xm[p,4])
                E_abs[5,p]>=(X[5,p]-Xm[p,5])
                E_abs[5,p]>=-(X[5,p]-Xm[p,5])
                E_abs[6,p]>=X[6,p]-Xm[p,6]
                E_abs[6,p]>=-(X[6,p]-Xm[p,6])
                E_abs[7,p]>=(1.0-sum(T[[2,3,4],p]))
                E_abs[7,p]>=-(1.0-sum(T[[2,3,4],p]))
                E_abs[8,p]>=(1.0-sum(T[[6,7,8],p]))
                E_abs[8,p]>=-(1.0-sum(T[[6,7,8],p]))
                E_abs[9,p]>=(1.0-sum(T[[10,11,12],p]))
                E_abs[9,p]>=-(1.0-sum(T[[10,11,12],p]))
        end)

        for i=1:Int(size(jump,2)/2)
            @NLconstraint(model,RTlqn[i,p]==sum(P2[i,j]*RTlqn[j,p] for j=1:Int(size(jump,2)/2))+RTs[i,p])
            @constraint(model,ERT_abs[i,p]>=RTlqn[i,p]-RT[p,i])
            @constraint(model,ERT_abs[i,p]>=-RTlqn[i,p]+RT[p,i])
        end
end

@objective(model,Min, sum(E_abs[i,p] for i=1:size(E_abs,1) for p=7:size(E_abs,2))+sum(ERT_abs))
JuMP.optimize!(model)
