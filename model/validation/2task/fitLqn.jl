using Printf,CPLEX,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

NC=[100000,1.0,1.0]
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

Xm=[0    1.0000    0.0000    0.0100    0.0000  465.9900;
    0    1.0000    0.0000    0.0100    0.0000  758.9900;
    0    1.0000    0.0000    0.0100    0.0000  927.9900;
    0    1.0000    0.0000    0.0100    0.0000  655.9900;
    ]

RT=[467.0000  466.0000  465.9900;
    760.0000  759.0000  758.9900;
    929.0000  928.0000  927.9900;
    657.0000  656.0000  655.9900
    ]

npoints=size(Xm,1)

#f(x::T, y::T) where {T<:Real} = -(-x-0+((-x+0)^2+10^-100)^(1.0/2))/2.0
f(x::T) where {T<:Real} = -(-x+((-x)^2+10^-200)^(1.0/2))/2.0
function ∇f(g::AbstractVector{T}, x::T, y::T) where {T<:Real}
    g[1] = 1/2 - (2*x - 2*y)/(4*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2))
    g[2] = (2*x - 2*y)/(4*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2)) + 1/2
    return
end
register(model, :min_, 1, f, autodiff=true) #∇f)

@variable(model,T[i=1:size(jump,1),j=1:npoints]>=0)
#@variable(model,G[i=1:Int(size(jump,2)/2),j=1:Int(size(jump,2)/2)]>=0)
@variable(model,MU[i=1:Int(size(jump,2)/2)]>=0)
@variable(model,X[i=1:size(jump,2),j=1:npoints]>=0)
@variable(model,P[i=1:Int(size(jump,2)/2),j=1:Int(size(jump,2)/2)]>=0)
@variable(model,E_abs[i=1:size(jump,2)+floor(Int, size(jump,2)/2),j=1:npoints]>=0)

@constraint(model,sum(P,dims=2).==1)

for p=1:npoints
@constraint(model,T[1,p]==delta*X[1,p])
@NLconstraint(model,T[2,p]==P[1,2]*MU[1]*X[2,p])
@NLconstraint(model,T[3,p]==P[1,3]*MU[1]*X[2,p])
@NLconstraint(model,T[4,p]==P[1,1]*MU[1]*X[2,p])

@constraint(model,T[5,p]==delta*X[3,p])
@NLconstraint(model,T[6,p]==P[2,3]*MU[2]*(min_(X[4,p]-NC[2])+NC[2]))
@NLconstraint(model,T[7,p]==P[2,1]*MU[2]*(min_(X[4,p]-NC[2])+NC[2]))
@NLconstraint(model,T[8,p]==P[2,2]*MU[2]*(min_(X[4,p]-NC[2])+NC[2]))


@constraint(model,T[9,p]==delta*X[5,p])
@NLconstraint(model,T[10,p]==P[3,1]*MU[3]*(min_(X[6,p]-NC[3])+NC[3]))
@NLconstraint(model,T[11,p]==P[3,2]*MU[3]*(min_(X[6,p]-NC[3])+NC[3]))
@NLconstraint(model,T[12,p]==P[3,3]*MU[3]*(min_(X[6,p]-NC[3])+NC[3]))

@constraint(model,jump'*T[:,p].==0)

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
                # E_abs[10,p]>=((X[1,p]+X[2,p])-RT[p,1]*sum(T[[2,3,4],p]))
                # E_abs[10,p]>=-((X[1,p]+X[2,p])-RT[p,1]*sum(T[[2,3,4],p]))
                # E_abs[11,p]>=((X[3,p]+X[4,p])-RT[p,2]*sum(T[[6,7,8],p]))
                # E_abs[11,p]>=-((X[3,p]+X[4,p])-RT[p,2]*sum(T[[6,7,8],p]))
                # E_abs[12,p]>=((X[5,p]+X[6,p])-RT[p,3]*sum(T[[10,11,12],p]))
                # E_abs[12,p]>=-((X[6,p]+X[6,p])-RT[p,3]*sum(T[[10,11,12],p]))
        end)

        # push!(obj,@NLexpression(model,abs(X[1,p]-Xm[p,1])+abs(X[2,p]-Xm[p,2])+
        #                        abs(X[3,p]-Xm[p,3])+abs(X[4,p]-Xm[p,4])+
        #                        abs(X[5,p]-Xm[p,5])+abs(X[6,p]-Xm[p,6])
        #                        +abs((X[5,p]+X[6,p])-RT[p,3]*MU[3]*(min_(X[6,p]-NC[3])+NC[3]))
        #                        +abs((X[3,p]+X[4,p])-RT[p,2]*MU[2]*(min_(X[4,p]-NC[2])+NC[2]))
        #                        +abs(sum(X[i,p] for i=1:6)-RT[p,1]*MU[1]*X[2,p])
        #                        ))
end

# @objective(model,Min,sum(Dmax)+((X[1,5]+X[1,6])-98.99*MU[3]*min(X[1,6],NC[3]))^2+
#                              ((X[1,3]+X[1,4])-99.0*MU[2]*min(X[1,4],NC[2]))^2+
#                              ((X[1,2]+X[1,1])-99.999*MU[1]*min(X[1,2],NC[1]))^2+
#
#                              ((X[2,5]+X[2,6])-630.9900*MU[3]*min(X[2,6],NC[3]))^2+
#                              ((X[2,3]+X[2,4])-631.0000*MU[2]*min(X[2,4],NC[2]))^2+
#                              ((X[2,2]+X[2,1])-631.9937*MU[1]*min(X[2,2],NC[1]))^2+
#
#                              ((X[3,5]+X[3,6])-547.00*MU[3]*min(X[3,6],NC[3]))^2+
#                              ((X[3,3]+X[3,4])-546.00*MU[2]*min(X[3,4],NC[2]))^2+
#                              ((X[3,2]+X[3,1])-545.9900*MU[1]*min(X[3,2],NC[1]))^2)
#@NLobjective(model,Min,sum(obj[k] for k=1:length(obj))+0.00*(MU[1]+MU[2]+MU[3]))
@objective(model,Min, sum(E_abs))
JuMP.optimize!(model)
