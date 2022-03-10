using Printf,Redis,Ipopt,JuMP,MAT,ParameterJuMP,Statistics,JSON

wdir=pwd()

#model = Model(()->MadNLP.Optimizer(print_level=MadNLP.INFO))
model = Model(Ipopt.Optimizer)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
#set_optimizer_attribute(model, "max_iter", 10000)
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

# min_(x,y)=-(-x-y+((-x+y)^2+10^-100)^(1.0/2))/2.0
# register(model, :min_, 2, min_, ∇f)

@variable(model,T[i=1:size(jumpR,1)]>=0)
@variable(model,X[i=1:size(jumpR,2)]>=0)
@variable(model,C == 0, Param())
@variable(model,NC[i=1:6]>=0)


@constraint(model,X[48-sum(toZero[1,1:48])]+X[1-sum(toZero[1,1:1])]==C)
@constraint(model,X[1-sum(toZero[1,1:1])]==sum(X[[5-sum(toZero[1,1:5]),
                                                 9-sum(toZero[1,1:9]),
                                                 26-sum(toZero[1,1:26]),
                                                 47-sum(toZero[1,1:47])]]))

@constraint(model,X[5-sum(toZero[1,1:5])]==X[7-sum(toZero[1,1:7])])
@constraint(model,X[9-sum(toZero[1,1:9])]==sum(X[[13-sum(toZero[1,1:13]),
                                                  20-sum(toZero[1,1:20]),
                                                  24-sum(toZero[1,1:24]),
                                                  ]]))

@constraint(model,X[26-sum(toZero[1,1:26])]==sum(X[[30-sum(toZero[1,1:30]),
                                                  37-sum(toZero[1,1:37]),
                                                  42-sum(toZero[1,1:42]),
                                                  46-sum(toZero[1,1:46]),
                                                  ]]))

@constraint(model,X[13-sum(toZero[1,1:13])]==sum(X[[15-sum(toZero[1,1:15]),
                                                    18-sum(toZero[1,1:18])
                                                  ]]))
@constraint(model,X[20-sum(toZero[1,1:20])]==sum(X[[22-sum(toZero[1,1:22]),
                                                  23-sum(toZero[1,1:23])
                                                ]]))
@constraint(model,X[17-sum(toZero[1,1:17])]==sum(X[[22-sum(toZero[1,1:22]),
                                                  15-sum(toZero[1,1:15])
                                                ]]))

@constraint(model,X[30-sum(toZero[1,1:30])]==sum(X[[32-sum(toZero[1,1:32]),
                                                  35-sum(toZero[1,1:35])
                                                ]]))

@constraint(model,X[37-sum(toZero[1,1:37])]==sum(X[[39-sum(toZero[1,1:39]),
                                                  40-sum(toZero[1,1:40])
                                                ]]))
@constraint(model,X[42-sum(toZero[1,1:42])]==sum(X[[44-sum(toZero[1,1:44]),
                                                  45-sum(toZero[1,1:45])
                                                ]]))

@constraint(model,sum(X[[7-sum(toZero[1,1:7]),
                         17-sum(toZero[1,1:17]),
                         18-sum(toZero[1,1:18]),
                         23-sum(toZero[1,1:23]),
                         24-sum(toZero[1,1:24]),
                         34-sum(toZero[1,1:34]),
                         35-sum(toZero[1,1:35]),
                         40-sum(toZero[1,1:40]),
                         45-sum(toZero[1,1:45]),
                         46-sum(toZero[1,1:46]),
                         47-sum(toZero[1,1:47]),
                         48-sum(toZero[1,1:48])]])==C)

@constraint(model,jump'*T.<=10^-10)
@constraint(model,jump'*T.>=-10^-10)
#@constraint(model,jump'*T.==0)
@constraint(model,NC.<=100)

NlProp=[
@NLexpression(model,X[15-sum(toZero[1,1:15])]/(X[15-sum(toZero[1,1:15])]+X[22-sum(toZero[1,1:22])]+10^-50)*X[17-sum(toZero[1,1:17])]*MU[17]),
@NLexpression(model,X[22-sum(toZero[1,1:22])]/(X[15-sum(toZero[1,1:15])]+X[22-sum(toZero[1,1:22])]+10^-50)*X[17-sum(toZero[1,1:17])]*MU[17]),

@NLexpression(model,X[18-sum(toZero[1,1:18])]/(X[18-sum(toZero[1,1:18])]+X[23-sum(toZero[1,1:23])]+10^-50)*NC[3]*MU[18]),
@NLexpression(model,X[23-sum(toZero[1,1:23])]/(X[18-sum(toZero[1,1:18])]+X[23-sum(toZero[1,1:23])]+10^-50)*NC[3]*MU[23]),

@NLexpression(model,X[32-sum(toZero[1,1:32])]/(X[32-sum(toZero[1,1:32])]+X[39-sum(toZero[1,1:39])]+X[44-sum(toZero[1,1:44])]+10^-50)*X[34-sum(toZero[1,1:34])]*MU[34]),
@NLexpression(model,X[39-sum(toZero[1,1:39])]/(X[32-sum(toZero[1,1:32])]+X[39-sum(toZero[1,1:39])]+X[44-sum(toZero[1,1:44])]+10^-50)*X[34-sum(toZero[1,1:34])]*MU[34]),
@NLexpression(model,X[44-sum(toZero[1,1:44])]/(X[32-sum(toZero[1,1:32])]+X[39-sum(toZero[1,1:39])]+X[44-sum(toZero[1,1:44])]+10^-50)*X[34-sum(toZero[1,1:34])]*MU[34]),

@NLexpression(model,X[35-sum(toZero[1,1:35])]/(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])]+10^-50)*NC[4]*MU[35]),
@NLexpression(model,X[40-sum(toZero[1,1:40])]/(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])]+10^-50)*NC[4]*MU[40]),
@NLexpression(model,X[45-sum(toZero[1,1:45])]/(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])]+10^-50)*NC[4]*MU[45]),

@NLexpression(model,X[7-sum(toZero[1,1:7])]/(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])]+10^-50)*NC[2]*MU[7]),
@NLexpression(model,X[24-sum(toZero[1,1:24])]/(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])]+10^-50)*NC[2]*MU[24]),
@NLexpression(model,X[46-sum(toZero[1,1:46])]/(X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])]+10^-50)*NC[2]*MU[46]),

@NLexpression(model,NC[1]*MU[47])]

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

# @constraint(model,X[17-sum(toZero[1,1:17])]<=1.1*MU[17]*(T[1]+T[2]))
#
# @constraint(model,X[18-sum(toZero[1,1:18])]<=1.1*MU[18]*T[3])
# @constraint(model,X[23-sum(toZero[1,1:23])]<=1.1*MU[23]*T[4])
#
# @constraint(model,X[34-sum(toZero[1,1:34])]<=1.1*MU[34]*(T[5]+T[6]+T[7]))
#
# @constraint(model,X[35-sum(toZero[1,1:35])]<=1.1*MU[35]*T[8])
# @constraint(model,X[40-sum(toZero[1,1:40])]<=1.1*MU[40]*T[9])
# @constraint(model,X[45-sum(toZero[1,1:45])]<=1.1*MU[45]*T[10])
#
# @constraint(model,X[7-sum(toZero[1,7])]<=1.1*MU[7]*T[11])
# @constraint(model,X[24-sum(toZero[1,1:24])]<=1.1*MU[24]*T[12])
# @constraint(model,X[46-sum(toZero[1,1:46])]<=1.1*MU[46]*T[13])
#
# @constraint(model,X[47-sum(toZero[1,1:47])]<=1.1*MU[47]*T[14])

#--------------

@constraint(model,NC[1]<=X[47-sum(toZero[1,1:47])])
@constraint(model,NC[2]<=X[7-sum(toZero[1,1:7])]+X[24-sum(toZero[1,1:24])]+X[46-sum(toZero[1,1:46])])
@constraint(model,NC[3]<=(X[18-sum(toZero[1,1:18])]+X[23-sum(toZero[1,1:23])]))
@constraint(model,NC[4]<=(X[35-sum(toZero[1,1:35])]+X[40-sum(toZero[1,1:40])]+X[45-sum(toZero[1,1:45])]))

alfa=1

NTNames=["NTrouter","NTfrontend","NTCatalogsvc","NTCartsvc","NTCatalogdb","NTCartdb"]
NCNames=["NCrouter","NCfrontend","NCCatalogsvc","NCCartsvc","NCCatalogdb","NCCartdb"]
conn = RedisConnection()
dt_sim=10.
nrep=1
tstep=100000
XS=zeros(tstep+1,size(jump,2))
XS[1,:]=zeros(1,size(jump,2))
XS[1,end]=3000
optNC=zeros(tstep,size(NC,1)+1)
stimes=[]
t=LinRange(0,(tstep+1)*dt_sim,(tstep+1))
Tsim=[]
Ie=0

cumAvgT=nothing
NT=nothing

i=1

w=get(conn, "w")
if(w==nothing)
    error("number of client not sampled")
else
    global w=parse(Float64,w)
end

while true

    set_value(C,w)

    #global tgt=round(alfa*0.999*w,digits=6)
    global tgt=w/7.00
    @objective(model,Min,0.5*((sum(T[15:20])-alfa*tgt)^2/(alfa*tgt))+0.5*sum(NC[i] for i=1:size(NC,1)-2)/((size(NC,1)-2)*100))
    push!(stimes,@elapsed JuMP.optimize!(model))
    status=termination_status(model)
    set(conn, "started","1")
    if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
        error(status)
    end

    global U=[0,value(X[47-sum(toZero[1,1:47])]),
     value(sum(X[[7-sum(toZero[1,1:7]),24-sum(toZero[1,1:24]),46-sum(toZero[1,1:46])]])),
     value(sum(X[[18-sum(toZero[1,1:18]),23-sum(toZero[1,1:23])]])),
     value(sum(X[[35-sum(toZero[1,1:35]),40-sum(toZero[1,1:40]),45-sum(toZero[1,1:45])]])),
     value(X[17-sum(toZero[1,1:17])]),
     value(X[34-sum(toZero[1,1:34])])
     ]

    global NU=[100000,
               value(X[1-sum(toZero[1,1:1])])+0.00002*Ie,
               value(X[1-sum(toZero[1,1:1])])+0.00002*Ie,
               value(X[9-sum(toZero[1,1:9])])+0.00002*Ie,
               value(X[26-sum(toZero[1,1:26])])+0.00002*Ie,
               100000,
               100000
               ]*1.20


    global NT=ceil.(NU)
    b=argmax(U[2:end]./(value.(NC)))
    for p=1:size(NC,1)
        #maximum(value.(NC[:,0])+ones(2)*(0.001*Ie),ones(2)*0.1)
        #if(p==b)
            optNC[i,p+1]=max(value(NC[p])+0.00002*Ie,0.0)
        #else
        #    optNC[i,p+1]=value(NC[p])
        #end
    end

    #println([value(X[1-sum(toZero[1,1:1])])])

    optNC[i,:]=optNC[i,:]*1.20

    optNC[i,6]=30000.
    optNC[i,7]=30000.


     for idx=1:length(NTNames)
         set(conn, NTNames[idx], @sprintf("%d",NT[idx+1]))
         set(conn, NCNames[idx], @sprintf("%.5f",optNC[i,idx+1]))
         tr=get(conn, "Tr")
         if(tr!=nothing)
             push!(Tsim,parse(Float64,tr))
         end
     end

    cumTr=cumsum(Tsim)./range(1,length=length(Tsim))

    if(length(Tsim)>0)
        global Ie += (alfa*tgt - cumTr[end])
    end

    #println(cumTr[end])

    w=get(conn, "w")
    if(w==nothing)
        error("Number of Clients not sampled")
    else
        global w=parse(Float64,w)
    end

    global i+=1
    set(conn, "stimes",JSON.json(stimes))
    sleep(1.)
    #break
end
