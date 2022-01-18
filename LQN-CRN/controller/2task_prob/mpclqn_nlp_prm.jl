using JuMP,MadNLPGraph,MadNLPMumps,MadNLP,SCIP,MAT,AmplNLWriter,ParameterJuMP,Bonmin_jll,Ipopt,CPLEX,MATLAB,Plots,Statistics,ProgressBars

function N(t,mod,period,shift)
    return sin(t/(period/(2*pi)))*mod+shift
end

function N2(t)
    return 3000#2*t
end

function rate(T,h)
    return [T[1,h],
            T[2,h],
            T[3,h],
            T[4,h],
            T[5,h],
            T[6,h],
            T[7,h],
            T[8,h],
            T[9,h],
            T[10,h],
            T[11,h],
            T[12,h],
            T[13,h],
            T[14,h],
            T[15,h]]
end

jump=[[ 0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0]
     [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0]
     [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  0  0  0  0  0  0  0  0  1  0  0]
     [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  0  0  0  0  1  0  0]
     [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0 -1  1  0  0]
     [ 0  0  0  0 -1  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0]
     [ 0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0]
     [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  1  0]
     [-1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  1]
     [ 1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1]
     [ 1  0  0  0  0  0  0  0  1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1]
     [ 1  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1]
     [ 1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0 -1]
     [ 1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0 -1]
     [ 1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  1  0  1  0  0 -1]]

min_(x,y)=-(-x-y+((-x+y)^2+10^-100)^(1.0/2))/2.0

# vars = matread("/Users/emilio/git/atom-replication/LQN-CRN/controller/2task_prob/activeClients.mat")
# activeClients = vars["NoOfActiveClients"]

alfa=1
dt=10^-3
H=5
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

X0=zeros(1,size(jump,2))
X0[end]=ceil(N(1,1500,(20*30),1500))
tgt=round(alfa*0.991*sum(X0[MU.>0]),digits=4)
tgtStory=[tgt]
XSode=nothing

#model = Model(Ipopt.Optimizer)
#register(model, :min_, 2, min_, autodiff=true)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
#set_optimizer_attribute(model, "acceptable_iter", 1)
#set_optimizer_attribute(model, "tol", 10^-5)
#set_optimizer_attribute(model, "hessian_approximation", "limited-memory")
#set_optimizer_attribute(model, "max_iter", 100)
#set_optimizer_attribute(model, "max_cpu_time", 1.)
#set_optimizer_attribute(model, "check_derivatives_for_naninf", "no")
#set_optimizer_attribute(model, "print_level", 0)

model = Model(()->MadNLP.Optimizer(print_level=MadNLP.ERROR,blas_num_threads=10,disable_garbage_collector=false,max_iter=500,linear_solver=MadNLPMumps))

@variable(model,X[i=1:size(jump,2),j=0:H]>=0)
@variable(model,X0p[i = 1:size(jump,2)] == 0, Param())
@variable(model,tgtp == tgt, Param())
@variable(model,T[i=1:size(jump,1),j=0:H]>=0)
@variable(model,E_abs[i=0:H]>=0)
@variable(model,NC[i=1:4,h=0:H]>=0)

@constraint(model,[i=1:size(jump,2)],X[i,0]==X0p[i])


for h=0:H
    @NLconstraint(model,T[1,h]==X[15,h]/(X[15,h]+X[19,h]+10^-100)*NC[3,h]*MU[15])
    @NLconstraint(model,T[2,h]==X[19,h]/(X[15,h]+X[19,h]+10^-100)*NC[3,h]*MU[19])

    @NLconstraint(model,T[3,h]==X[28,h]/(X[28,h]+X[32,h]+X[36,h]+10^-100)*NC[4,h]*MU[28])
    @NLconstraint(model,T[4,h]==X[32,h]/(X[28,h]+X[32,h]+X[36,h]+10^-100)*NC[4,h]*MU[32])
    @NLconstraint(model,T[5,h]==X[36,h]/(X[28,h]+X[32,h]+X[36,h]+10^-100)*NC[4,h]*MU[36])

    @NLconstraint(model,T[6,h]==X[7,h]/(X[7,h]+X[20,h]+X[37,h]+10^-100)*NC[2,h]*MU[7])
    @NLconstraint(model,T[7,h]==X[20,h]/(X[7,h]+X[20,h]+X[37,h]+10^-100)*NC[2,h]*MU[20])
    @NLconstraint(model,T[8,h]==X[37,h]/(X[7,h]+X[20,h]+X[37,h]+10^-100)*NC[2,h]*MU[37])

    @constraint(model,T[9,h]==NC[1,h]*MU[38])

    @constraint(model,T[10,h]==MU[end]*X[end,h]*(1.0/3))
    @constraint(model,T[11,h]==MU[end]*X[end,h]*(1.0/6))
    @constraint(model,T[12,h]==MU[end]*X[end,h]*(1.0/6))
    @constraint(model,T[13,h]==MU[end]*X[end,h]*(1.0/9))
    @constraint(model,T[14,h]==MU[end]*X[end,h]*(1.0/9))
    @constraint(model,T[15,h]==MU[end]*X[end,h]*(1.0/9))
end

#integration of the fast part
jumpt=jump'
for h=0:H-1
    prop=rate(T,h) #derivata del sistema all'istante t
    for i=1:size(jumpt,1)
        k1=@expression(model,0)
        k2=@expression(model,0)
        k3=@expression(model,0)
        k4=@expression(model,0)
        for j=1:size(jumpt,2)
            k1=@expression(model,k1+jumpt[i,j]*prop[j])
        end
        for j=1:size(jumpt,2)
            k2=@expression(model,k2+jumpt[i,j]*(prop[j]+(dt/2.)*k1))
        end
        for j=1:size(jumpt,2)
            k3=@expression(model,k3+jumpt[i,j]*(prop[j]+(dt/2.)*k2))
        end
        for j=1:size(jumpt,2)
            k4=@expression(model,k4+jumpt[i,j]*(prop[j]+dt*k3))
        end
        @constraint(model,X[i,h+1]==dt/6*(k1+2*k2+2*k3+k4)+X[i,h])
    end
end

@constraint(model,E_abs1[h=1:H],E_abs[h]-X[size(jump,2),h]>=-tgtp)
@constraint(model,E_abs2[h=1:H],E_abs[h]+X[size(jump,2),h]>=tgtp)

@constraint(model,nc1[h=0:H],NC[1,h]<=X[38,h])
@constraint(model,nc2[h=0:H],NC[2,h]<=X[7,h]+X[20,h]+X[37,h])
@constraint(model,nc3[h=0:H],NC[3,h]<=X[15,h]+X[19,h])
@constraint(model,nc4[h=0:H],NC[4,h]<=X[28,h]+X[32,h]+X[36,h])

dt_sim=60.
nrep=1
tstep=400
XS=zeros(tstep+1,size(jump,2),nrep)
optNC=zeros(tstep,size(NC,1)+1,nrep)
stimes=zeros(nrep*(tstep+1))
t=LinRange(0,(tstep+1)*dt_sim,(tstep+1))
i=1
Tsim=[]

for b=1:nrep
    x0=X0
    global XSode=X0
    global XS[1,:,b]=X0
    Ie=0

    #for i=1:tstep
    #for i in ProgressBar(1:tstep)
    @objective(model,Min,sum(E_abs)+0.0000000001*sum(NC[i,h] for i=1:size(NC,1) for h=0:H))

    while(i<=tstep)

        for h=0:H
            set_start_value(NC[1,h],0)
            set_start_value(NC[2,h],0)
            set_start_value(NC[3,h],0)
            set_start_value(NC[4,h],0)
        end

        for k=1:size(jump,2)
            set_value(X0p[k],x0[k])
        end


        JuMP.optimize!(model)
        status=termination_status(model)
        if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
            #error(status)
        end
        local soltime=MOI.get(model, MOI.SolveTime())
        global stimes[i+tstep*(b-1)]=soltime

        x0=reshape(value.(X[:,end]),1,size(jump,2))
        global XSode=vcat(XSode,x0)

        #println(size(XSode,2))
        println(maximum(abs.(diff(XSode[end-1:end,end],dims=1))))
        println("solved")
        if(size(XSode,2)>1 && maximum(abs.(diff(XSode[end-1:end,end],dims=1)))<=10^-6)

            for p=1:size(NC,1)
                #maximum(value.(NC[:,0])+ones(2)*(0.001*Ie),ones(2)*0.1)
                optNC[i,p+1,b]=max(value(mean(NC[p,0:end-1]))+0.0001*Ie,0.0)
            end

            println(optNC[i,:,b])

            println("simulating")
            mat"cd(\"/Users/emilio/git/atom-replication/model/validation/2task_prob\")"
            #mat"Xsim=lqn($XS($i,:,$b),$MU,[inf,inf,inf,inf],[inf,inf,inf,1.5],$dt_sim,1,$dt_sim);"
            mat"Xsim=lqn($XS($i,:,$b),$MU,[inf,inf,inf,inf,inf],$optNC($i,:,$b),$dt_sim,1,$dt_sim);"
            @mget Xsim
            global XS[i+1,:,b]=Xsim[:,end]

            push!(Tsim,mean(Xsim[end,:])*MU[end])

            # for h=0:H
            #     set_start_value(NC[1,h],optNC[i,1,b])
            #     set_start_value(NC[2,h],optNC[i,2,b])
            #     set_start_value(NC[3,h],optNC[i,3,b])
            # end


            #global U=[mean(XS[1:i+1,19])/value(NC[1]),sum(mean(XS[1:i+1,[7,11,18]]))/value(NC[2]),mean(XS[1:i+1,17])/value(NC[3])]
            #println("util",U," ",argmax(U))
            Ie += (tgt - XS[i,end,b])

            if(mod(i,1)==0)
                global X0=zeros(1,size(jump,2))
                global X0[end]=ceil(N(i,1500,(20*30),1500))
                global XS[i+1,end,b]+=ceil(N(i,1500,(20*30),1500))-ceil(N(i-1,1500,(20*30),1500))

                global tgt=round(alfa*0.991*sum(X0[MU.>0]),digits=4)
                for h=0:H
                    set_value(tgtp,tgt)
                end
                println(tgt," ",sum(X0[MU.>0]))
             end

             push!(tgtStory,tgt)

             global i+=1
             x0=X0
        end
    end
end

closeall()
cumavg=cumsum(XS[:,end,1]) ./ range(1,size(XS,1),step=1)
e=abs((cumavg[end]-tgt)*100/tgt)
println(e)

println([mean(stimes),maximum(stimes),minimum(stimes)])
println(mean(optNC[:,:,1],dims=1))
#Controlled layered three-tier system by varying #threads HW/SW at each tier. Simulation (i.e., 100 runs) Vs Target reguirement.
#println(mean(mean(XS[:,4,:],dims=2))," ",mean(stimes))
#hline([tgt],label = "Target",reuse=false,legend=:bottomright)
plot(t,tgtStory,label = "Target",reuse=false,legend=:bottomright)
plot!(t,XS[:,end,1],label = "Controlled-simulation",legend=:bottomright)
#plot!(t[2:end],Tsim,label = "Controlled-simulation",legend=:bottomright)
plot!(t,cumavg,label = "Controlled-simulation",legend=:bottomright)
xlabel!("Time(s)")
ylabel!("QueueLength")
ylims!((0.0,maximum(XS)))
