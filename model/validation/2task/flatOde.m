function [t,y] = flatOde(X0,P,MU,NT,NC)
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

jump=[  -1   +1   +0   +0   +0   +0;
        +0   -1   +1   +0   +0   +0;
        +0   -1   +0   +0   +1   +0;
        +1   -1   +0   +0   +0   +0;
        +0   +0   -1   +1   +0   +0;
        +0   +0   +0   -1   +1   +0;
        +1   +0   +0   -1   +0   +0;
        +0   +0   +1   -1   +0   +0;
        +0   +0   +0   +0   -1   +1;
        +1   +0   +0   +0   +0   -1;
        +0   +0   +1   +0   +0   -1;
        +0   +0   +0   +0   +1   -1;
        ];

T = @(X)propensities_2state(X,p);

% X=zeros(1000,size(X0,2));
% X(1,:)=X0;
% for i=1:size(X,1)
%
%     k1=dt*jump'*T(X(i,:));
%     k2=dt*(jump'*T(X(i,:)))+k1/2;
%     k3=dt*(jump'*T(X(i,:)))+k2/2;
%     k4=dt*(jump'*T(X(i,:)))+k3;
%
%     X(i+1,:)=1/6*(k1+2*k2+2*k3+k4)+X(i,:)';
%     %X(i+1,:)=k1+X(i,:)';
% end

opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode15s(@(t,y) jump'*T(y),[0,Inf], X0,opts);

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
Rate = [p.delta*X(1);
        p.P(1,2)*p.MU(1)*min(X(2),p.NC(1));
        p.P(1,3)*p.MU(1)*min(X(2),p.NC(1));
        p.P(1,1)*p.MU(1)*min(X(2),p.NC(1));
        p.delta*X(3);
        p.P(2,3)*p.MU(2)*min(X(4),p.NC(2));
        p.P(2,1)*p.MU(2)*min(X(4),p.NC(2));
        p.P(2,2)*p.MU(2)*min(X(4),p.NC(2));
        p.delta*X(5);
        p.P(3,1)*p.MU(3)*min(X(6),p.NC(3));
        p.P(3,2)*p.MU(3)*min(X(6),p.NC(3));
        p.P(3,3)*p.MU(3)*min(X(6),p.NC(3));
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