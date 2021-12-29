using JuMP, NLopt,Ipopt, MATLAB,Plots,Statistics,ProgressBars

function rate(T,h)
    return [T[1,h],
            T[2,h],
            T[3,h],
            T[4,h],
            T[5,h]]
end


jump=zeros(5,7)

j=[[+1   +1 +0  +0 +0 +0 -1],
      [+0,  -1,  +1,  +1,  +0,  +0,  +0],
      [+0,  +0,  +0,  -1,  +1,  +0,  +0],
      [+0,  +0,  -1,  +0,  -1,  +1,  +0],
      [-1,  +0,  +0,  +0,  +0,  -1,  +1]]

for i=1:size(j,1)
    row=j[i]
    jump[i,:]=row
end

alfa=-5
#min_(x,y)=(1.0/alfa)*log(exp(alfa*x)+exp(alfa*y))
min_(x,y)=-(-x-y+((-x+y)^2+10^(-20))^(1.0/2))/2
#min_(x)=(x*exp(alfa*x))/(exp(alfa*x)+1)

#min_(x,y)=-(-x-y+((-x+y)^2+10^-20)^(1/2))/2.0
#max_(x,y)=(x^11+y^11)^(1/11)

delta=10^4
dt=10^(-4)
H=10
MU=[10^3,10^3,10^3,10^3,10^3,10^3,1]
X0=[0,0,0,0,0,0,300]
tgt=100

model = Model(Ipopt.Optimizer)
set_optimizer_attribute(model, "linear_solver", "pardiso")
#set_optimizer_attribute(model, "acceptable_iter", 1)
#set_optimizer_attribute(model, "tol", 10^-8)
#set_optimizer_attribute(model, "max_iter", 10000)
set_optimizer_attribute(model, "print_level", 0)

#model = Model(NLopt.Optimizer)
register(model, :min_, 2, min_, autodiff=true)
# register(model, :eps, 0, eps; autodiff = true)
#set_optimizer_attribute(model, "algorithm", :LD_SLSQP)
# set_optimizer_attribute(model, "ftol_rel", 10^(-5))
# set_optimizer_attribute(model, "xtol_rel", 10^(-5))
#set_optimizer_attribute(model, "algorithm", :LD_MMA)


@variable(model,X[i=1:7,j=0:H]>=0)
@variable(model,T[i=1:5,j=0:H]>=0)
@variable(model,E_abs[i=0:H]>=0)
@variable(model,NC[i=1:2,h=0:H]>=0)
#@variable(model,NT[i=1:2]>=0)

@constraint(model,NC.<=5000)
@constraint(model,X0c[i=1:7],X[i,0]==0)

for h=0:H
    @constraint(model,T[1,h]==MU[7]*X[7,h])
    @constraint(model,T[2,h]==delta*X[2,h])
    @constraint(model,T[3,h]==delta*X[4,h])
    @NLconstraint(model,T[4,h]==(X[5,h]+10^-20)/(X[5,h]+10^-20)*min_(NC[2,h],X[5,h])*MU[5])
    @NLconstraint(model,T[5,h]==min_(NC[1,h],X[6,h])*MU[6])
    #@NLconstraint(model,T[4,h]==NC[2,h]*MU[5])
    #@NLconstraint(model,T[5,h]==NC[1,h]*MU[6])
end

#integration of the fast part
jumpt=jump'
for h=0:H-1
    prop=rate(T,h)
    for i=1:size(jumpt,1)
        #println("X",i,"_",h+1)
        xi=@NLexpression(model,0)
        for j=1:size(jumpt,2)
            #println(prop[j]*jumpt[i,j])
            xi=@NLexpression(model,xi+jumpt[i,j]*prop[j])
        end
        @NLconstraint(model,X[i,h+1]==xi*dt+X[i,h])
    end
    #@constraint(model,[i=1:6],X[i,h+1]==dy[i]*dt+X[i,h])
    #integrate the slow system for one step
    # local dy2=(jump'*rate(0,T,h))'
    # @constraint(model,[i=1:6],X[i,h+1]==dy2[i]*dt+X[i,h])
    # @NLconstraint(model,X[1,h+1]==(-T[1,h]+T[2,h])*dt+X[1,h])
    # @NLconstraint(model,X[2,h+1]==(T[1,h])*dt+X[2,h])
    # @NLconstraint(model,X[3,h+1]==(-T[4,h])*dt+X[3,h])
    # @NLconstraint(model,X[4,h+1]==(-T[2,h] + T[4,h])*dt+X[4,h])
    # @NLconstraint(model,X[5,h+1]==X[5,h])
    # @NLconstraint(model,X[6,h+1]==-T[4,h]*dt+X[6,h])
end

#add absolute value constraint
for h=0:H
    @constraints(model, begin
           E_abs[h]>=(X[7,h]-tgt)
           E_abs[h]>=-(X[7,h]-tgt)
    end)
end

# @constraint(model,[h=0:H],NC[1,h]<=X[6,h])
# @constraint(model,[h=0:H],NC[2,h]<=X[5,h])

#@objective(model,Min,sum(E_abs)+0.000001*sum(NC/500))
#@NLobjective(model,Min,sum((T[1,h]-tgt)^2 for h=0:H)+0.0000001*sum(NC[i] for i=1:2)/500)

dt_sim=dt*5
nrep=1
tstep=4000
XS=zeros(tstep+1,7,nrep)
optNC=zeros(tstep+1,3,nrep)
stimes=zeros(nrep*(tstep+1))
t=LinRange(0,(tstep+1)*dt_sim,(tstep+1))

for b=1:nrep
    local x0=X0
    global XS[1,:,b]=X0
    for i=1:tstep
    #for i in ProgressBar(1:tstep)

        for k=1:7
            #println(k," ",x0[k])
            set_normalized_rhs(X0c[k],x0[k])
        end
        #
        # if(i>1)
        #     for h=0:H
        #         set_start_value(NC[1,h], optNC[i-1,2,b])
        #         set_start_value(NC[2,h], optNC[i-1,3,b])
        #     end
        # end

        # if(i>1)
        #     @NLobjective(model,Min,sum(E_abs[h] for h=0:H)+0.000001*(sum((NC[i,h]/500)^2 for i=1:2 for h=0:H)))
        # else
            @objective(model,Min,sum((T[1,h]-tgt)^2 for h=0:H))
        # end

        JuMP.optimize!(model)
        status=termination_status(model)
        if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
            #error(status)
        end
        local soltime=MOI.get(model, MOI.SolveTime())
        global stimes[i+tstep*(b-1)]=soltime
        #local Nto=Int.(round.(value.(NC)))
        # println(value.(NT[1])-x0[3]-x0[4])
        # println(value.(NT[1]-X[3,0]-X[4,0]))
        #println(x0)
        #println(value.(X))
        #println(value.(NC))
        optNC[i,2:end,b]=value.(NC[:,0])
        #println(value.(S),value.(NT))
        #println(value.(X[:,0]))
        #println(X0c)
        #println(value.(X0c))
        #local Nto=Real.(rand(1:10,1,2))
        #sprintln(x0,Sopt,Nto,soltime)
        mat"cd(\"/Users/emilio/git/atom-replication/model/validation/_2tier\")"
        mat"Xsim=lqn($x0,$MU,[inf,inf,inf],$optNC($i,:,$b),$dt_sim,1,$dt_sim);"
        @mget Xsim
        x0=Xsim[:,end]
        #x0=value.(X[:,end])
        println(x0," ",optNC[i,2:end,b])
        global XS[i+1,:,b]=x0
    end
end

cumavg=cumsum(XS[:,end,1]) ./ range(1,size(XS,1),step=1)

#Controlled layered three-tier system by varying #threads HW/SW at each tier. Simulation (i.e., 100 runs) Vs Target reguirement.
#println(mean(mean(XS[:,4,:],dims=2))," ",mean(stimes))
hline([tgt],label = "Target",reuse=false,legend=:bottomright)
plot!(t,XS[:,end,1],label = "Controlled-simulation",legend=:topright)
plot!(t,cumavg,label = "Controlled-simulation",legend=:topright)
xlabel!("Time(s)")
ylabel!("QueueLength")
ylims!((0.0,maximum(XS)))
