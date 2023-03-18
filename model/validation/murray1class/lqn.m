function X = lqn(X0,MU,NT,NC,TF,rep,dt)
import Gillespie.*

% Make sure vector components are doubles
X0 = double(X0);
MU = double(MU);

% Make sure all vectors are row vectors
if(iscolumn(X0))
    X0 = X0';
end
if(iscolumn(MU))
    MU = MU';
end
if(iscolumn(NT))
    NT = NT';
end
if(iscolumn(NT))
    NC = NC';
end

p.MU = MU; 
p.NT = NT;
p.NC = NC;
p.delta = 10^5; % context switch rate (super fast)

%states name
%X(1)=XuserWork_2Accept;
%X(2)=Xaccept_a;
%X(3)=Xaccept_2AppRequest;
%X(4)=XappRequest_a;
%X(5)=XappRequest_2dbAccess2;
%X(6)=XdbAccess_a;
%X(7)=XdbAccess_e;
%X(8)=XappRequest_e;
%X(9)=Xaccept_2dbAccess;
%X(10)=Xaccept_e;
%X(11)=XuserWork_e;


%task ordering
%1=Users;
%2=App;
%3=HTTPServer;
%4=DB;

%devo aggiungere molteplicità tra appRequest e dbAccess
% //                          tra accept e dbAccess


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  +0,  +1,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0;
               -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
               ];
    
tspan = [0, TF];
pfun = @propensities_2state;
 
X = zeros(length(X0), ceil(TF/dt) + 1, rep);
for i = 1:rep
    [t, x] = directMethod(stoich_matrix, pfun, tspan, X0, p);
    tsin = timeseries(x,t);
    tsout = resample(tsin, linspace(0, TF, ceil(TF/dt)+1), 'zoh');
    X(:, :, i) = tsout.Data';
end

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
    Rate = [p.MU(11)*X(11);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(3)-(X(3)+X(9)+X(10)));
    		X(4)/(X(4))*p.delta*min(X(4),p.NT(2)-(X(5)+X(8)));
    		X(6)/(X(6))*p.delta*min(X(6),p.NT(4)-(X(7)));
    		X(5)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(4))*p.MU(7);
    		X(3)/(X(3))*X(8)/(X(8))*min(X(8),p.NC(2))*p.MU(8);
    		X(9)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(4))*p.MU(7);
    		X(1)/(X(1))*X(10)/(X(10))*min(X(10),p.NC(3))*p.MU(10);
    		];
    Rate(isnan(Rate))=0;
end