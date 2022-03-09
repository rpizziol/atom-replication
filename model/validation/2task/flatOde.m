function [t,y,Ts] = flatOde(X0,P,MU,NT,NC)
% Make sure vector components are doubles
X0 = double(X0);
MU = double(MU);
P = double(P);

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
p.P = P;
p.delta = 10^5; % context switch rate (super fast)

jump=[ -1   +1   +0   +0;
       -1   +0   +1   +0;
       -1   +0   +0   +1;
       +0   +0   +0   +0;
       +1   -1   +0   +0;
       +0   -1   +1   +0;
       +0   -1   +0   +1;
       +0   +0   +0   +0;
       +1   +0   -1   +0;
       +0   +1   -1   +0;
       +0   +0   -1   +1;
       +0   +0   +0   +0;
       +1   +0   +0   -1;
       +0   +1   +0   -1;
       +0   +0   +1   -1;
       +0   +0   +0   +0;
       ];

T = @(X)propensities_2state(X,p);

opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode23s(@(t,y) jump'*T(y),[0,Inf], X0,opts);

Ts=T(y(end,:));

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
Rate = [p.P(1,2)*p.MU(1)*X(1);
        p.P(1,3)*p.MU(1)*X(1);
        p.P(1,4)*p.MU(1)*X(1);
        p.P(1,1)*p.MU(1)*X(1);
        
        (X(2)/sum(X([2,3,4])))*p.P(2,1)*p.MU(2)*min(sum(X([2,3,4])),p.NC(2));
        (X(2)/sum(X([2,3,4])))*p.P(2,3)*p.MU(2)*min(sum(X([2,3,4])),p.NC(2));
        (X(2)/sum(X([2,3,4])))*p.P(2,4)*p.MU(2)*min(sum(X([2,3,4])),p.NC(2));
        (X(2)/sum(X([2,3,4])))*p.P(2,2)*p.MU(2)*min(sum(X([2,3,4])),p.NC(2));
        
        (X(3)/sum(X([2,3,4])))*p.P(3,1)*p.MU(3)*min(sum(X([2,3,4])),p.NC(2));
        (X(3)/sum(X([2,3,4])))*p.P(3,2)*p.MU(3)*min(sum(X([2,3,4])),p.NC(2));
        (X(3)/sum(X([2,3,4])))*p.P(3,4)*p.MU(3)*min(sum(X([2,3,4])),p.NC(2));
        (X(3)/sum(X([2,3,4])))*p.P(3,3)*p.MU(3)*min(sum(X([2,3,4])),p.NC(2));
        
        (X(4)/sum(X([2,3,4])))*p.P(4,1)*p.MU(4)*min(sum(X([2,3,4])),p.NC(2));
        (X(4)/sum(X([2,3,4])))*p.P(4,2)*p.MU(4)*min(sum(X([2,3,4])),p.NC(2));
        (X(4)/sum(X([2,3,4])))*p.P(4,3)*p.MU(4)*min(sum(X([2,3,4])),p.NC(2));
        (X(4)/sum(X([2,3,4])))*p.P(4,4)*p.MU(4)*min(sum(X([2,3,4])),p.NC(2));
    ];
Rate(isnan(Rate))=0;
end

function [x,isterm,dir] = eventfun(t,y,jump,T)    
    dy = jump'*T(y);
    %x = norm(dy) - 1e-5;
    x=max(abs(dy)) - 1e-10;
    isterm = 1;
    dir = 0;
end
