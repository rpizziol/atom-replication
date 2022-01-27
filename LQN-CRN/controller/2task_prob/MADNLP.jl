using Printf,Ipopt,MadNLP,Plots,MadNLPMumps,JuMP,MAT,ProgressBars,ParameterJuMP,MATLAB,Statistics

cwd=pwd()

#model = Model(()->MadNLP.Optimizer(linear_solver=MadNLPMumps))
model = Model(Ipopt.Optimizer)
set_optimizer_attribute(model, "linear_solver", "pardiso")
set_optimizer_attribute(model, "max_iter", 10000)
#set_optimizer_attribute(model, "tol", 10^-10)
set_optimizer_attribute(model, "print_level", 0)

jump=[0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0 -1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0 -1  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0 -1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  1  0  0  0  0  0  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0 -1  1  0  0  0  0  0  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0 -1  1  0  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  1  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0 -1  0  0  0  0  0  1  0  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0 -1  1  0  0;
      0  0  0  0 -1  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0;
      0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0;
      0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  1  0;
     -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  1;
      1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  1  0  0  0  1  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  1  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  1  0  1  0  0  0  0  0  0  0  0 -1;
      1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  1  0  0  0 -1;]

#riduco il numero di variabili del problema, quello che cambia è la dimensione dello stato non il numero di transzioni
r=jump[:,:].==zeros(size(jump,1),1)
toZero=sum(r,dims=1).==size(jump,1) #se 1 indica che queta colonna è da eliminare
jumpR=jump[:,.!toZero[1,:]]

P_Home=0.63
P_Catalog=0.32
P_Cart=0.05

P_List=1.0/2
P_Item=1.0/2

P_Get=1.0/3
P_Add=1.0/3
P_Rmv=1.0/3

MU=ones(1,size(jump,2))*-1


MU[18]=1.0/(2.2*10^-3) #LIST
MU[23]=1.0/(1.9*10^-3) #ITEM

MU[7]=1.0/(2.1*10^-3) #Home
MU[24]=1.0/(3.7*10^-3) #Catalog
MU[46]=1.0/(5.1*10^-3) #Carts

MU[35]= 1.0/(4.8*10^-3)  #Get
MU[40]= 1.0/(17.4*10^-3) #Add
MU[45]= 1.0/(5.6*10^-3)  #Del

MU[17]=1.0/(1.3*10^-3) #CatQry
MU[34]=1.0/(2.2*10^-3) #CartQry

MU[47]=1.0/(1.2*10^-3) #Address
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

min_(x,y)=-(-x-y+((-x+y)^2+10^-100)^(1.0/2))/2.0
register(model, :min_, 2, min_, ∇f)

@variable(model,T[i=1:size(jumpR,1)]>=0)
@variable(model,X[i=1:size(jumpR,2)]>=0)
@variable(model,C == 0, Param())
@variable(model,NC[i=1:6]>=0)

@constraint(model,sum(X)==C)
@constraint(model,jump'*T.<=10^-6)
@constraint(model,jump'*T.>=-10^-6)
@constraint(model,NC.<=100)

NlProp=[
@NLexpression(model,X[15-sum(toZero[1,1:15])]/(X[15-sum(toZero[1,1:15])]+X[22-sum(toZero[1,1:22])])*min_(X[17-sum(toZero[1,1:17])],NC[5])*MU[17]),
@NLexpression(model,X[22-sum(toZero[1,1:22])]/(X[15-sum(toZero[1,1:15])]+X[22-sum(toZero[1,1:22])])*min_(X[17-sum(toZero[1,1:17])],NC[5])*MU[17]),

@NLexpression(model,X[18-sum(toZero[1,1:18])]/(X[18-sum(toZero[1,1:18])]+X[23-sum(toZero[1,1:23])])*NC[3]*MU[18]),
@NLexpression(model,X[23-sum(toZero[1,1:23])]/(X[18-sum(toZero[1,1:18])]+X[23-sum(toZero[1,1:23])])*NC[3]*MU[23]),

@NLexpression(model,X[32-sum(toZero[1,1:32])]/(X[32-sum(toZero[1,1:32])]+X[39-sum(toZero[1,1:39])]+X[44-sum(toZero[1,1:44])])*min_(X[34-sum(toZero[1,1:34])],NC[6])*MU[34]),
@NLexpression(model,X[39-sum(toZero[1,1:39])]/(X[32-sum(toZero[1,1:32])]+X[39-sum(toZero[1,1:39])]+X[44-sum(toZero[1,1:44])])*min_(X[34-sum(toZero[1,1:34])],NC[6])*MU[34]),
@NLexpression(model,X[44-sum(toZero[1,1:44])]/(X[32-sum(toZero[1,1:32])]+X[39-sum(toZero[1,1:39])]+X[44-sum(toZero[1,1:44])])*min_(X[34-sum(toZero[1,1:34])],NC[6])*MU[34]),

@NLexpression(model,X[35-sum(toZero[1,1:35])]/(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])])*min_(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])],NC[4])*MU[35]),
@NLexpression(model,X[40-sum(toZero[1,1:40])]/(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])])*min_(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])],NC[4])*MU[40]),
@NLexpression(model,X[45-sum(toZero[1,1:45])]/(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])])*min_(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])],NC[4])*MU[45]),

@NLexpression(model,X[7-sum(toZero[1,1:7])]/(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])])*min_(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])],NC[2])*MU[7]),
@NLexpression(model,X[24-sum(toZero[1,1:24])]/(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])])*min_(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])],NC[2])*MU[24]),
@NLexpression(model,X[46-sum(toZero[1,1:46])]/(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])])*min_(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])],NC[2])*MU[46]),

@NLexpression(model,min_(X[47-sum(toZero[1,1:47])],NC[1])*MU[47])]

LProp=[@expression(model,MU[48]*X[48-sum(toZero[1,1:48])]*P_Home),
@expression(model,MU[48]*X[48-sum(toZero[1,1:48])]*P_Catalog*P_List),
@expression(model,MU[48]*X[48-sum(toZero[1,1:48])]*P_Catalog*P_Item),
@expression(model,MU[48]*X[48-sum(toZero[1,1:48])]*P_Cart*P_Get),
@expression(model,MU[48]*X[48-sum(toZero[1,1:48])]*P_Cart*P_Add),
@expression(model,MU[48]*X[48-sum(toZero[1,1:48])]*P_Cart*P_Rmv)]

#--------rate
for propIdx=1:length(NlProp)
    @NLconstraint(model,T[propIdx]==NlProp[propIdx])
end

for propIdx=1:length(LProp)
    @NLconstraint(model,T[propIdx+length(NlProp)]==LProp[propIdx])
end

#-----response time constraints

@constraint(model,X[17-sum(toZero[1,1:17])]<=1.1*MU[17]*(T[1]+T[2]))

@constraint(model,X[18-sum(toZero[1,1:18])]<=1.1*MU[18]*T[3])
@constraint(model,X[23-sum(toZero[1,1:23])]<=1.1*MU[23]*T[4])

@constraint(model,X[34-sum(toZero[1,1:34])]<=1.1*MU[34]*(T[5]+T[6]+T[7]))

@constraint(model,X[35-sum(toZero[1,1:35])]<=1.1*MU[35]*T[8])
@constraint(model,X[40-sum(toZero[1,1:40])]<=1.1*MU[40]*T[9])
@constraint(model,X[45-sum(toZero[1,1:45])]<=1.1*MU[45]*T[10])

@constraint(model,X[7-sum(toZero[1,7])]<=1.1*MU[7]*T[11])
@constraint(model,X[24-sum(toZero[1,1:24])]<=1.1*MU[24]*T[12])
@constraint(model,X[46-sum(toZero[1,1:46])]<=1.1*MU[46]*T[13])

@constraint(model,X[47-sum(toZero[1,1:47])]<=1.1*MU[47]*T[14])

#--------------

alfa=1.0

dt_sim=60.
nrep=1
tstep=200
XS=zeros(tstep+1,size(jump,2))
XS[1,:]=zeros(1,size(jump,2))
XS[1,end]=3000
optNC=zeros(tstep,size(NC,1)+1)
stimes=[]
t=LinRange(0,(tstep+1)*dt_sim,(tstep+1))
Tsim=[]
Ie=0

for i in ProgressBar(1:tstep)

    #w=rand(1000:3000)
    w=XS[1,end]

    set_value(C,w)

    global tgt=round(alfa*0.999*w,digits=6)
    @objective(model,Min,0.99999*(X[end]-tgt)^2+0.0000006*sum(NC[i] for i=1:size(NC,1)))
    push!(stimes,@elapsed JuMP.optimize!(model))
    status=termination_status(model)
    if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
        error(status)
    end

    for p=1:size(NC,1)
        #maximum(value.(NC[:,0])+ones(2)*(0.001*Ie),ones(2)*0.1)
        optNC[i,p+1]=max(value(NC[p])+0.00001*Ie,0.0)
    end

    # optNC[i,6]=1000
    # optNC[i,7]=1000

    NT=ceil.([0,value(sum(X[1:end-1])),
     value(sum(X[[7-sum(toZero[1,1:7]),24-sum(toZero[1,1:24]),46-sum(toZero[1,1:46]),
              13-sum(toZero[1,1:13]),20-sum(toZero[1,1:20]),
              30-sum(toZero[1,1:30]),37-sum(toZero[1,1:37]),42-sum(toZero[1,1:42])]])),
     value(sum(X[[15-sum(toZero[1,1:13]),20-sum(toZero[1,1:20])]])),
     value(sum(X[[30-sum(toZero[1,1:30]),37-sum(toZero[1,1:37]),42-sum(toZero[1,1:42])]])),
     value(X[17-sum(toZero[1,1:17])]),
     value(X[34-sum(toZero[1,1:34])])
     ])


    println("simulating")
    mat"cd(\"/Users/emilio/git/atom-replication/model/validation/2task_prob\")"
    #mat"Xsim=lqn($XS($i,:),$MU,[inf,inf,inf,inf,inf,inf,inf],[inf,inf,inf,inf,inf,inf,inf],$dt_sim,1,$dt_sim);"
    mat"Xsim=lqn($XS($i,:),$MU,$NT,$optNC($i,:),$dt_sim,1,$dt_sim);"
    @mget Xsim
    global XS[i+1,:]=Xsim[:,end]

    println(NT)
    println(optNC[i,:])
    push!(Tsim,mean(Xsim[end,:])*MU[end])

    global Ie += (tgt - XS[i+1,end])
end

closeall()
hline([tgt],label = "Target",reuse=false,legend=:bottomright)
plot!(t,XS[:,end],label = "Controlled-simulation",legend=:bottomright)
xlabel!("Time(s)")
ylabel!("QueueLength")
ylims!((0.0,maximum(XS)))
