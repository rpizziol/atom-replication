using Jedis,Printf,Ipopt,JuMP,MAT,ParameterJuMP,Mongoc,UUIDs
include("getTR.jl")


wdir=pwd()
redisHost="127.0.0.1"
mongoClient = Mongoc.Client(redisHost, 27017)

#model = Model(()->MadNLP.Optimizer(print_level=MadNLP.INFO))
model = Model(Ipopt.Optimizer)
#set_optimizer_attribute(model, "linear_solver", "pardiso")
set_optimizer_attribute(model, "max_iter", 100000)
#set_optimizer_attribute(model, "tol", 10^-10)
#set_optimizer_attribute(model, "hessian_approximation", "limited-memory")
set_optimizer_attribute(model, "print_level", 0)

jump=[  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1;
	    +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  -1  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    -1  +0  +0  +0  +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  -1  +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  -1  +1  +1  +0  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +1  +0  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  -1  +1  +0  +0  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  +0  +0  +0  +0  +0  +0  -1  +1  +1  +0  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +1  +0  +0  +0  +0  +0  +0  -1  +1  +0  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  +1  +0  +0  +0  +0  -1  +1  +0  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  +0  +0  +0  -1  +1  +0;
	    +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  -1  +0  +0  +0  -1  +1;
		+0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +0  +1  +0  +0  -1  +0;
    ];

delta=10^6
maxNC=15
maxNT=200

MS=["MSauth","MSvalidateid","MSbookflights","MSupdateMiles","MScancelbooking",
	"MSgetrewardmiles","MSqueryflights","MSviewprofile","MSupdateprofile"]

params = matread(@sprintf("%s/git/nodejsMicro/src/params.mat",homedir()))
MU=params["MU"]
#MU=MU*1.0

# MU=ones(1,size(jump,2))*-1

# MU[5]=9.2569; #XValidate_e;
# MU[6]=5.5851; #XLogin_e;
# MU[9]=5.6264; #XViewProfile_e;
# MU[12]=3.7859; #XUpdateProfile_e;
# MU[15]=9.0137; #XQuery_e;
# MU[20]=13.1285; #XUpdateMiles_e;
# MU[23]=15.2845; #XGetReward_e;
# MU[24]=5.6010; #XBook_e;
# MU[29]=7.1427; #XCancel_e;
# MU[30]=3.6319; #XBrowse_e;

@variable(model,T[i=1:size(jump,1)]>=0)
@variable(model,X[i=1:size(jump,2)]>=0)
@variable(model,C == 0, Param())
@variable(model,NC[2:10]>=0)
@variable(model,NT[2:10]>=0)

#devo sottrarre gli stati che contano il numero di richieste sincrone, altrimneti non si conservano il numero di job
@constraint(model,sum(X[i] for i in [2,4,5,6,8,9,11,12,14,15,17,19,20,22,23,24,26,29,30])==C)

@constraint(model,jump'*T.==0)
@constraint(model,NC.<=maxNC)
@constraint(model,NT.<=maxNT)



#--------rate
#-(-a-b+sqrt((-a+b)^2+10^-2))/2;

#p.delta*min(p.NT(2)-(X(3)+X(6)),X(2));
#Tm2=@NLexpression(model,delta*-(-(NT[2]-(X[3]+X[6]))-X[2]+sqrt((-(NT[2]-(X[3]+X[6]))+X[2])^2+alpha))/2)
@variable(model,Tm2>=0)
@constraint(model,Tm2<=NT[2]-(X[3]+X[6]))
@constraint(model,Tm2<=X[2])
#p.delta*min(p.NT(3)-(X(5)),X(4));
#Tm3=@NLexpression(model,delta*-(-(NT[3]-X[5])-X[4]+sqrt((-(NT[3]-X[5])+X[4])^2+alpha))/2)
@variable(model,Tm3>=0)
@constraint(model,Tm3<=X[4])
@constraint(model,Tm3<=NT[3]-X[5])
#min(X(5),p.NC(3));
#Tm4=@NLexpression(model,-(-NC[3]-X[5]+sqrt((-NC[3]+X[5])^2+alpha))/2)
@variable(model,Tm4>=0)
@constraint(model,Tm4<=X[5])
@constraint(model,Tm4<=0.7*NC[3])

#min(X(6),p.NC(2));
#Tm5=@NLexpression(model,-(-NC[2]-X[6]+sqrt((-NC[2]+X[6])^2+alpha))/2)
@variable(model,Tm5>=0)
@constraint(model,Tm5<=X[6])
@constraint(model,Tm5<=0.7*NC[2])
#p.delta*min(p.NT(9)-(X(9)),X(8));
#Tm6=@NLexpression(model,delta*-(-(NT[9]-X[9])-X[8]+sqrt((-(NT[9]-X[9])+X[8])^2+alpha))/2)
@variable(model,Tm6>=0)
@constraint(model,Tm6<=NT[9]-X[9])
@constraint(model,Tm6<=X[8])
#min(X(9),p.NC(9));
#Tm7=@NLexpression(model,-(-NC[9]-X[9]+sqrt((-NC[9]+X[9])^2+alpha))/2)
@variable(model,Tm7>=0)
@constraint(model,Tm7<=0.7*NC[9])
@constraint(model,Tm7<=X[9])
#p.delta*min(p.NT(10)-(X(12)),X(11));
#Tm8=@NLexpression(model,delta*-(-(NT[10]-X[12])-X[11]+sqrt((-(NT[10]-X[12])+X[11])^2+alpha))/2)
@variable(model,Tm8>=0)
@constraint(model,Tm8<=NT[10]-X[12])
@constraint(model,Tm8<=X[11])
#min(p.NC(10),X(12));
#Tm9=@NLexpression(model,-(-NC[10]-X[12]+sqrt((-NC[10]+X[12])^2+alpha))/2)
@variable(model,Tm9>=0)
@constraint(model,Tm9<=0.7*NC[10])
@constraint(model,Tm9<=X[12])
#p.delta*min(p.NT(8)-(X(15)),X(14));
#Tm10=@NLexpression(model,delta*-(-(NT[8]-X[15])-X[14]+sqrt((-(NT[8]-X[15])+X[14])^2+alpha))/2)
@variable(model,Tm10>=0)
@constraint(model,Tm10<=NT[8]-X[15])
@constraint(model,Tm10<=X[14])
#min(p.NC(8),X(15));
#Tm11=@NLexpression(model,-(-NC[8]-X[15]+sqrt((-NC[8]+X[15])^2+alpha))/2)
@variable(model,Tm11>=0)
@constraint(model,Tm11<=0.7*NC[8])
@constraint(model,Tm11<=X[15])
#p.delta*min(p.NT(4)-(X(18)+X(21)+X(24)),X(17));
#Tm12=@NLexpression(model,delta*-(-(NT[4]-(X[18]+X[21]+X[24]))-X[17]+sqrt((-(NT[4]-(X[18]+X[21]+X[24]))+X[17])^2+alpha))/2)
@variable(model,Tm12>=0)
@constraint(model,Tm12<=NT[4]-(X[18]+X[21]+X[24]))
@constraint(model,Tm12<=X[17])
#p.delta*min(p.NT(5)-(X(20)),X(19));
#Tm13=@NLexpression(model,delta*-(-(NT[5]-X[20])-X[19]+sqrt((-(NT[5]-X[20])+X[19])^2+alpha))/2)
@variable(model,Tm13>=0)
@constraint(model,Tm13<=NT[5]-(X[20]))
@constraint(model,Tm13<=X[19])
#p.delta*min(p.NT(7)-(X(23)),X(22));
#Tm15=@NLexpression(model,delta*-(-(NT[7]-X[23])-X[22]+sqrt((-(NT[7]-X[23])+X[22])^2+alpha))/2)
@variable(model,Tm15>=0)
@constraint(model,Tm15<=NT[7]-(X[23]))
@constraint(model,Tm15<=X[22])
#min(p.NC(4),X(24));
#Tm17=@NLexpression(model,-(-NC[4]-X[24]+sqrt((-NC[4]+X[24])^2+alpha))/2)
@variable(model,Tm17>=0)
@constraint(model,Tm17<=0.7*NC[4])
@constraint(model,Tm17<=X[24])
#p.delta*min(p.NT(6)-(X(27)+X(28)+X(29)),X(26));
#Tm18=@NLexpression(model,delta*-(-(NT[6]-(X[27]+X[28]+X[29]))-X[26]+sqrt((-(NT[6]-(X[27]+X[28]+X[29]))+X[26])^2+alpha))/2)
@variable(model,Tm18>=0)
@constraint(model,Tm18<=NT[6]-(X[27]+X[28]+X[29]))
@constraint(model,Tm18<=X[26])
#min(X(29),p.NC(6));
#Tm21=@NLexpression(model,-(-NC[6]-X[29]+sqrt((-NC[6]+X[29])^2+alpha))/2)
@variable(model,Tm21>=0)
@constraint(model,Tm21<=0.7*NC[6])
@constraint(model,Tm21<=X[29])

#min(p.NC(5),X(20));
#TmGPS1=@NLexpression(model,-(-NC[5]-X[20]+sqrt((-NC[5]+X[20])^2+alpha))/2)
@variable(model,TmGPS1>=0)
@constraint(model,TmGPS1<=NC[5])
@constraint(model,TmGPS1<=X[20])

#min(p.NC(7),X(23));
#TmGPS2=@NLexpression(model,-(-NC[7]-X[23]+sqrt((-NC[7]+X[23])^2+alpha))/2)
@variable(model,TmGPS2>=0)
@constraint(model,TmGPS2<=NC[7])
@constraint(model,TmGPS2<=X[23])


@constraint(model,  T[1]==MU[30]*X[30])
@NLconstraint(model,T[2]==delta*Tm2)
@NLconstraint(model,T[3]==delta*Tm3)
@NLconstraint(model,T[4]==Tm4*MU[5])
@NLconstraint(model,T[5]==Tm5*MU[6])
@NLconstraint(model,T[6]==delta*Tm6)
@NLconstraint(model,T[7]==0.5*Tm7*MU[9])
@NLconstraint(model,T[8]==delta*Tm8)
@NLconstraint(model,T[9]==Tm9*MU[12])
@NLconstraint(model,T[10]==delta*Tm10)
@NLconstraint(model,T[11]==Tm11*MU[15])
@NLconstraint(model,T[12]==delta*Tm12)
@NLconstraint(model,T[13]==delta*Tm13)
@NLconstraint(model,T[14]==0.5*X[18]/(X[18]+X[27])*TmGPS1*MU[20])
@NLconstraint(model,T[15]==delta*Tm15)
@NLconstraint(model,T[16]==0.5*X[21]/(X[21]+X[28])*TmGPS2*MU[23])
@NLconstraint(model,T[17]==Tm17*MU[24])
@NLconstraint(model,T[18]==delta*Tm18)
@NLconstraint(model,T[19]==X[27]/(X[18]+X[27])*TmGPS1*MU[20])
@NLconstraint(model,T[20]==X[28]/(X[21]+X[28])*TmGPS2*MU[23])
@NLconstraint(model,T[21]==0.5*Tm21*MU[29])
@NLconstraint(model,T[22]==0.5*Tm21*MU[29])


@constraint(model,X[1]==X[2]+X[3]+X[6])
@constraint(model,X[3]==X[4]+X[5])
@constraint(model,X[7]==X[8]+X[9])
@constraint(model,X[10]==X[11]+X[12])
@constraint(model,X[13]==X[14]+X[15])
@constraint(model,X[16]==X[17]+X[18]+X[21]+X[24])
@constraint(model,X[18]+X[27]==X[19]+X[20])
@constraint(model,X[21]+X[28]==X[22]+X[23])
@constraint(model,X[25]==X[26]+X[27]+X[28]+X[29])

#-----response time constraints
#@constraint(model,(X[1]+X[5])<=(MU[5]+P_c1*MU[3]+P_c2*MU[4])*1.02*T[1])
#@constraint(model,(X[3])<=MU[3]*1.02*T[4])
#@constraint(model,(X[4])<=MU[4]*1.02*T[5])

# Set up channels, publisher and subscriber clients
channels = ["users"]
subscriber = Client(host=redisHost, port=6379)
redis_cli=Client(host=redisHost, port=6379)

# Begin the subscription
stop_fn(msg) = msg[end] == "close";  # stop the subscription loop if the message matches

println("started")
set("ctrlStrt","1";client=redis_cli)

global Ik=0
global stimes=[]
global outfile=string(UUIDs.uuid4())

subscribe(channels...; stop_fn=stop_fn, client=subscriber) do msg
	#w=parse(Float64, msg[end])
	w=parse(Float64,get("users";client=redis_cli))
	set_value(C,w)
	global stimes
	global outfile

    @objective(model,Max,0.5*(T[1])*1.0/(0.75*w)-0.5*(sum(NC)+0*sum(NT))/(maxNC*9+0*maxNT*9))
    stime=@elapsed JuMP.optimize!(model)
    push!(stimes,stime)
    
    global status=termination_status(model)
    if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
        error(status)
    end

	Tmk=getTr(mongoClient,10,"MSauth")
	if(typeof(Tmk)!=Nothing)
		global Ik=Ik+((0.75*w)-Tmk)
	else
		println("error")
		global Ik=0
	end

	for m=1:length(NC)
		set(@sprintf("%s_hw",MS[m]),@sprintf("%.3f",value(NC[m+1])+0.0001*Ik);client=redis_cli)
	end
	
	matwrite(@sprintf("./data/%s.mat",outfile), Dict(
        "stimes" => stimes
    );)
	
end


#--------------
# npoint=40
# NCopt=zeros(9,npoint)
# NTopt=zeros(9,npoint)
# stimeOpt=zeros(1,npoint)
# clients=rand(1,npoint)'*500
# #clients=LinRange(1,100, npoint);
# #clients=[1]
#
# for i=1:size(clients,1)
#     global w=round(clients[i])
#     set_value(C,w)
#
#     @objective(model,Max,0.5*(T[1])*15/(w)-0.5*(sum(NC)+sum(NT))/(maxNC*10+maxNT*10))
#     global stimes=@elapsed JuMP.optimize!(model)
#     global status=termination_status(model)
#     if(status!=MOI.LOCALLY_SOLVED && status!=MOI.ALMOST_LOCALLY_SOLVED)
#         error(status)
#     end
#
#     #RTv=[value(X[1]+X[5])/value(T[1]),value(X[3])/value(T[4]),value(X[4])/value(T[5])];
#     #Tv=[value(T[1]),value(T[4]),value(T[5])]
#
#     NCopt[:,i]=value.(NC)
#     NTopt[:,i]=value.(NT)
#     stimeOpt[i]=stimes
# end
#
# matwrite("re.mat", Dict(
# 	"NC_opt" => NCopt,
# 	"NT_opt" => NTopt,
# 	"Clients" =>  collect(clients),
# 	"rtime_opt" => stimeOpt
# );)
