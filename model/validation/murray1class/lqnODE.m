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


% Jump matrix
jump=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
      +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
      +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0;
      +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0;

      +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0;

      +0,  +0,  -1,  +0,  +0,  +1,  +0,  -1,  +1,  +0,  +0;
      +0,  +0,  +0,  +1,  +0,  +0,  +0,  -1,  +0,  +0,  +0;

      +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0;
      +0,  +0,  +0,  +0,  +0,  +1,  -1,  +0,  +0,  +0,  +0;

      -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
      ];

T = @(X)propensities_2state(X,p);
opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode15s(@(t,y) jump'*T(y),linspace(0,5,5001), X0,opts);
%[t,y]=ode15s(@(t,y) jump'*T(y),[0,inf], X0,opts);
ssR=T(y(end,:)');

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
    Rate = [p.MU(11)*X(11);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(3)-(X(3)+X(9)+X(10)));
    		X(4)/(X(4))*p.delta*min(X(4),p.NT(2)-(X(5)+X(8)));
    		X(6)/(X(6))*p.delta*min(X(6),p.NT(4)-(X(7)));

    		X(5)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(4))*p.MU(7)

    		X(3)/(X(3))*X(8)/(X(8))*min(X(8),p.NC(2))*p.MU(8)*1/3;
            X(3)/(X(3))*X(8)/(X(8))*min(X(8),p.NC(2))*p.MU(8)*2/3;
    		
            X(9)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(4))*p.MU(7)*1/5;
            X(9)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(4))*p.MU(7)*4/5;

    		X(1)/(X(1))*X(10)/(X(10))*min(X(10),p.NC(3))*p.MU(10);
    		];
    Rate(isnan(Rate))=0;
end

function [x,isterm,dir] = eventfun(t,y,jump,T)
dy = jump'*T(y);
x = norm(dy) - 1e-8;
% x=max(abs(dy)) - 1e-8;
isterm = 1;
dir = 0;
end