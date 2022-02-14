function [t,y] = lqnOde(X0,MU,NT,NC,dt)
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

jump=[+1,  +1,  +0,  +0,  +0,  +0,  -1;
    +0,  -1,  +1,  +0,  +0,  +0,  +0;
    -1,  +0,  -1,  +1,  +1,  +0,  +0;
    +0,  +0,  +0,  +0,  -1,  +1,  +0;
    +0,  +0,  +0,  -1,  +0,  -1,  +1;
    ];

T = @(X)propensities_2state(X,p);

opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode15s(@(t,y) jump'*T(y),[0,Inf], X0,opts);

end

function [x,isterm,dir] = eventfun(t,y,jump,T)
dy = jump'*T(y);
%x = norm(dy) - 1e-5;
x=max(abs(dy)) - 1e-10;
isterm = 1;
dir = 0;
end


% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
Rate = [p.MU(7)*X(7);
    X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)));
    X(1)/(X(1))*X(3)/(X(3))*min(X(3),p.NC(2))*p.MU(3);
    X(5)/(X(5))*p.delta*min(X(5),p.NT(3)-(X(6)));
    X(4)/(X(4))*X(6)/(X(6))*min(X(6),p.NC(3))*p.MU(6);
    ];
Rate(isnan(Rate))=0;
end
