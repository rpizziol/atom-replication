function [t,y,ssR] = lqnODE(X0,MU,NT,NC,TF,DT)
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
%X(1)=XB_2E1;
%X(2)=XE1_a;
%X(3)=XE1_E1_c1;
%X(4)=XE1_e;
%X(5)=XB_e;


%task ordering
%1=C;
%2=T;


% Jump matrix
jump=[+1,  +1,  +0,  +0,  -1;
      +0,  -1,  +1,  +0,  +0;
      +0,  +0,  -1,  +1,  +0;
      -1,  +0,  +0,  -1,  +1;
    ];

T = @(X)propensities_2state(X,p);
opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode15s(@(t,y) jump'*T(y),linspace(0,TF,round(TF/DT)+1), X0,opts);

ssR=T(y(end,:)');

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
Rate = [p.MU(5)*X(5);
        p.delta*min(X(2),p.NT(2)-(X(3)+X(4)));
        X(3)/(X(3)+X(4))*min(X(3)+X(4),p.NC(2))*p.MU(3);
        X(4)/(X(3)+X(4))*min(X(3)+X(4),p.NC(2))*p.MU(4);
    ];
Rate(isnan(Rate))=0;
end

function [x,isterm,dir] = eventfun(t,y,jump,T)
dy = jump'*T(y);
x = norm(dy) - 1e-5;
%x=max(abs(dy)) - 1e-5;
isterm = 1;
dir = 0;
end