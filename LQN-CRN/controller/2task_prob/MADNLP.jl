using Printf,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

#model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMumps))
model = Model(Ipopt.Optimizer)
set_optimizer_attribute(model, "linear_solver", "pardiso")
set_optimizer_attribute(model, "print_level", 0)

jump=[0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  0  0  0  0  0  0  0  0  1  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  0  0  0  0  1  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  1  0  0;
      0  0  0  0 -1  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0;
      0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  1  0;
     -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  1;
      1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  1  0  1  0  0 -1;]

#riduco il numero di variabili del problema, quello che cambia è la dimensione dello stato non il numero di transzioni
r=jump[:,:].==zeros(size(jump,1),1)
toZero=sum(r,dims=1).==size(jump,1) #se 1 indica che queta colonna è da eliminare
jumpR=jump[:,.!toZero[1,:]]


MU=ones(1,size(jump,2))*-1

MU[15]=1.0/(2.2*10^-3) #LIST
MU[19]=1.0/(1.9*10^-3) #ITEM

MU[7]=1.0/(2.1*10^-3) #Home
MU[20]=1.0/(3.7*10^-3) #Catalog
MU[37]=1.0/(5.1*10^-3) #Carts

MU[28]= 1.0/(4.8*10^-3)  #Get
MU[32]= 1.0/(17.4*10^-3) #Add
MU[36]= 1.0/(5.6*10^-3)  #Del

MU[38]=1.0/(1.2*10^-3) #Address
MU[end]=1.0/7 #think

f(x::T, y::T) where {T<:Real} = -(-x-y+((-x+y)^2+10^-100)^(1.0/2))/2.0
function ∇f(g::AbstractVector{T}, x::T, y::T) where {T<:Real}
    g[1] = 1/2 - (2*x - 2*y)/(4*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2))
    g[2] = (2*x - 2*y)/(4*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2)) + 1/2
    return
end
function ∇²f(g::AbstractVector{T}, x::T, y::T) where {T<:Real}
    g[1,1] = (2*x - 2*y)^2/(8*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(3/2)) - 1/(2*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2))
    g[1,2] = 1/(2*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2)) - (2*x - 2*y)^2/(8*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(3/2))
    g[2,1] = 1/(2*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2)) - (2*x - 2*y)^2/(8*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(3/2))
    g[2,2] = (2*x - 2*y)^2/(8*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(3/2)) - 1/(2*((x - y)^2 + 1/10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)^(1/2))
    return
end

#register(model, :min_, 2, f, ∇f,∇²f)
# f(x::Float64) = x^2
# ∇f(x::Float64) = 2 * x
# ∇²f(x::Float64) = 2.0
#register(model, :foo, 1, f, ∇f, ∇²f)

min_(x,y)=-(-x-y+((-x+y)^2+10^-100)^(1.0/2))/2.0
register(model, :min_, 2, min_, ∇f)

@variable(model,T[i=1:size(jumpR,1)]>=0)
@variable(model,X[i=1:size(jumpR,2)]>=0)
@variable(model,C == 0, Param())
@variable(model,NC[i=1:4]>=0)

@constraint(model,sum(X)==C)
@constraint(model,jump'*T.<=10^-6)


#--------rate
@NLconstraint(model,T[1]==X[15-sum(toZero[1,1:15])]/(X[15-sum(toZero[1,1:15])]+X[19-sum(toZero[1,1:19])])*min_(X[15-sum(toZero[1,1:15])]+X[19-sum(toZero[1,1:19])],NC[3])*MU[15])
@NLconstraint(model,T[2]==X[19-sum(toZero[1,1:19])]/(X[15-sum(toZero[1,1:15])]+X[19-sum(toZero[1,1:19])])*min_(X[15-sum(toZero[1,1:15])]+X[19-sum(toZero[1,1:19])],NC[3])*MU[19])

@NLconstraint(model,T[3]==X[28-sum(toZero[1,1:28])]/(X[28-sum(toZero[1,1:28])]+X[32-sum(toZero[1,1:32])]+X[36-sum(toZero[1,1:36])])*min_(X[28-sum(toZero[1,1:28])]+X[32-sum(toZero[1,1:32])]+X[36-sum(toZero[1,1:36])],NC[4])*MU[28])
@NLconstraint(model,T[4]==X[32-sum(toZero[1,1:32])]/(X[28-sum(toZero[1,1:28])]+X[32-sum(toZero[1,1:32])]+X[36-sum(toZero[1,1:36])])*min_(X[28-sum(toZero[1,1:28])]+X[32-sum(toZero[1,1:32])]+X[36-sum(toZero[1,1:36])],NC[4])*MU[32])
@NLconstraint(model,T[5]==X[36-sum(toZero[1,1:36])]/(X[28-sum(toZero[1,1:28])]+X[32-sum(toZero[1,1:32])]+X[36-sum(toZero[1,1:36])])*min_(X[28-sum(toZero[1,1:28])]+X[32-sum(toZero[1,1:32])]+X[36-sum(toZero[1,1:36])],NC[4])*MU[36])

@NLconstraint(model,T[6]==X[7-sum(toZero[1,1:7])]/(X[7-sum(toZero[1,1:7])]+X[20-sum(toZero[1,1:20])]+X[37-sum(toZero[1,1:37])])*min_(X[7-sum(toZero[1,1:7])]+X[20-sum(toZero[1,1:20])]+X[37-sum(toZero[1,1:37])],NC[2])*MU[7])
@NLconstraint(model,T[7]==X[20-sum(toZero[1,1:20])]/(X[7-sum(toZero[1,1:7])]+X[20-sum(toZero[1,1:20])]+X[37-sum(toZero[1,1:37])])*min_(X[7-sum(toZero[1,1:7])]+X[20-sum(toZero[1,1:20])]+X[37-sum(toZero[1,1:37])],NC[2])*MU[20])
@NLconstraint(model,T[8]==X[37-sum(toZero[1,1:37])]/(X[7-sum(toZero[1,1:7])]+X[20-sum(toZero[1,1:20])]+X[37-sum(toZero[1,1:37])])*min_(X[7-sum(toZero[1,1:7])]+X[20-sum(toZero[1,1:20])]+X[37-sum(toZero[1,1:37])],NC[2])*MU[37])

@NLconstraint(model,T[9]==min_(X[38-sum(toZero[1,1:38])],NC[1])*MU[38])

@constraint(model,T[10]==MU[end]*X[end]*(1.0/3))
@constraint(model,T[11]==MU[end]*X[end]*(1.0/6))
@constraint(model,T[12]==MU[end]*X[end]*(1.0/6))
@constraint(model,T[13]==MU[end]*X[end]*(1.0/9))
@constraint(model,T[14]==MU[end]*X[end]*(1.0/9))
@constraint(model,T[15]==MU[end]*X[end]*(1.0/9))

#-----response time constraints
# @constraint(model,X[15-sum(toZero[1,1:15])]<=1.1*MU[15]*T[1])
# @constraint(model,X[19-sum(toZero[1,1:19])]<=1.1*MU[19]*T[2])
#
# @constraint(model,X[28-sum(toZero[1,1:28])]<=1.1*MU[28]*T[3])
# @constraint(model,X[32-sum(toZero[1,1:32])]<=1.1*MU[32]*T[4])
# @constraint(model,X[36-sum(toZero[1,1:36])]<=1.1*MU[36]*T[5])
#
# @constraint(model,X[7-sum(toZero[1,7])]<=1.1*MU[7]*T[6])
# @constraint(model,X[20-sum(toZero[1,1:20])]<=1.1*MU[20]*T[7])
# @constraint(model,X[37-sum(toZero[1,1:37])]<=1.1*MU[37]*T[8])
#
# @constraint(model,X[38-sum(toZero[1,1:38])]<=1.1*MU[38]*T[9])

#--------------

alfa=1

dt_sim=300.
nrep=1
tstep=30
XS=zeros(tstep+1,size(jump,2))
XS[1,:]=zeros(1,size(jump,2))
XS[1,end]=3000
optNC=zeros(tstep,size(NC,1)+1)
stimes=[]
t=LinRange(0,(tstep+1)*dt_sim,(tstep+1))
Tsim=[]
Ie=0

for i in ProgressBar(1:tstep)
    # set_start_value(NC[1],0)
    # set_start_value(NC[2],0)
    # set_start_value(NC[3],0)
    # set_start_value(NC[4],0)

    #w=rand(1000:3000)
    w=3000

    set_value(C,w)

    global tgt=round(alfa*0.9987*w,digits=4)
    @NLobjective(model,Min,(X[end]-tgt)^2+0.0001*sum(NC[i] for i=1:size(NC,1)))
    push!(stimes,@elapsed JuMP.optimize!(model))
    status=termination_status(model)
    if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
        error(status)
    end

    for p=1:size(NC,1)
        #maximum(value.(NC[:,0])+ones(2)*(0.001*Ie),ones(2)*0.1)
        optNC[i,p+1]=max(value(NC[p])+0.0000*Ie,0.0)
    end

    NT=2*ceil.(optNC[i,:])

    print(NT)

    println("simulating")
    mat"cd(\"/Users/emilio/git/atom-replication/model/validation/2task_prob\")"
    #mat"Xsim=lqn($XS($i,:),$MU,[inf,inf,inf,inf,inf],[inf,inf,inf,inf,inf],$dt_sim,1,$dt_sim);"
    mat"Xsim=lqn($XS($i,:),$MU,[inf,8,4,2,2],$optNC($i,:),$dt_sim,1,$dt_sim);"
    @mget Xsim
    global XS[i+1,:]=Xsim[:,end]

    push!(Tsim,mean(Xsim[end,:])*MU[end])

    global Ie += (tgt - XS[i+1,end])
end

closeall()
hline([tgt],label = "Target",reuse=false,legend=:bottomright)
plot!(t,XS[:,end],label = "Controlled-simulation",legend=:bottomright)
xlabel!("Time(s)")
ylabel!("QueueLength")
ylims!((0.0,maximum(XS)))

2*ceil.([value(sum(X[1:end-1])),
 value(sum(X[[7-sum(toZero[1,1:7]),20-sum(toZero[1,1:20]),37-sum(toZero[1,1:37]),
          13-sum(toZero[1,1:13]),17-sum(toZero[1,1:17]),
          26-sum(toZero[1,1:26]),30-sum(toZero[1,1:30]),34-sum(toZero[1,1:34])]])),
 value(sum(X[[15-sum(toZero[1,1:13]),19-sum(toZero[1,1:17])]])),
 value(sum(X[[28-sum(toZero[1,1:26]),32-sum(toZero[1,1:30]),36-sum(toZero[1,1:34])]]))
 ])

value(sum(X[[5-sum(toZero[1,1:5]),9-sum(toZero[1,1:9]),22-sum(toZero[1,1:22])]]))
