function [t,y,ssR] = lqnODE(X0,MU,NT,NC)
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
%X(6)=XdbAccess1_a;
%X(7)=XdbAccess1_e;
%X(8)=XappRequest_e;
%X(9)=Xaccept_2dbAccess;
%X(10)=XdbAccess2_a;
%X(11)=XdbAccess2_e;
%X(12)=Xaccept_e;
%X(13)=XuserWork_e;


%task ordering
%1=Users;
%2=App;
%3=HTTPServer;
%4=DB1; considero il task 4 e 5 gli stessi e applico GPS
%5=DB2;


% Jump matrix
jump=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
      +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
      +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
      +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
      +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0;

      +0,  +0,  -1,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0;
      +0,  +0,  +0,  +1,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0;
      
      +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0;

      +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0;
      +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  -1,  +0,  +0;

      -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
    ];

T = @(X)propensities_2state(X,p);
opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode15s(@(t,y) jump'*T(y),[0,Inf], X0,opts);

ssR=T(y(end,:)');

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
Rate = [p.MU(13)*X(13); %thinking
    p.delta*min(X(2),p.NT(3)-(X(3)+X(9)+X(12))); %acquiring HTTP
    p.delta*min(X(4),p.NT(2)-(X(5)+X(8))); %acquiring APP

    X(6)/(X(6)+X(10))*p.delta*min(X(6)+X(10),p.NT(4)-(X(7)+X(11))); %acquiring DB1
    X(7)/(X(7)+X(11))*min(X(7)+X(11),p.NC(4))*p.MU(7); %executing DB1

    min(X(8),p.NC(2))*p.MU(8)*3/3; %executing APP
    min(X(8),p.NC(2))*p.MU(8)*0/3; %executing APP

    X(10)/(X(6)+X(10))*p.delta*min(X(6)+X(10),p.NT(4)-(X(7)+X(11))); %acquiring DB2

    X(11)/(X(7)+X(11))*min(X(7)+X(11),p.NC(4))*p.MU(7)*1/5; %executing DB2
    X(11)/(X(7)+X(11))*min(X(7)+X(11),p.NC(4))*p.MU(7)*4/5; %executing DB2

    min(X(12),p.NC(3))*p.MU(12); %executing HTTP
    ];
Rate(isnan(Rate))=0;
end

function [x,isterm,dir] = eventfun(t,y,jump,T)
dy = jump'*T(y);
x = norm(dy) - 1e-5;
% x=max(abs(dy)) - 1e-5;
isterm = 1;
dir = 0;
end