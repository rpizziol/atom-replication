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
%X(1)=XBrowse_2E1;
%X(2)=XE1_a;
%X(3)=XE1_ChoiceE1;
%X(4)=XE1_BlkSynch;
%X(5)=XE1_2E2Synch;
%X(6)=XE2_a;
%X(7)=XE2_e;
%X(8)=XE1_BlkAsynch;
%X(9)=XE1_2E2Asynch;
%X(10)=XE1_e;
%X(11)=XBrowse_browse;


%task ordering
%1=C;
%2=T1;
%3=T2;

p.P_synch=0;
p.P_asynch=1-p.P_synch;


% Jump matrix
jump=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
       +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
       +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
       +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0;
       +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0;
       +0,  +0,  -1,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0;
       +0,  +0,  +0,  +0,  +0,  +1,  +0,  -1,  +1,  +1,  +0;
       +0,  +0,  +0,  +0,  -1,  +0,  -1,  +0,  +0,  +1,  +0;
       +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +0,  +0;
       -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
               ];

T = @(X)propensities_2state(X,p);
opts = odeset('Events',@(t,y)eventfun(t,y,jump,T));
[t,y]=ode15s(@(t,y) jump'*T(y),[0,Inf], X0,opts);

ssR=T(y(end,:)');

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
    Rate = [p.MU(11)*X(11);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)+X(4)+X(5)+X(8)+X(9)+X(10)));
    		p.delta*X(3)*p.P_synch;
    		p.delta*X(4);
    		X(6)/(X(6))*p.delta*min(X(6),p.NT(3)-(X(7)));
    		p.delta*X(3)*p.P_asynch;
    		p.delta*X(8);
    		X(5)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(3))*p.MU(7);
    		X(9)/(X(5)+X(9))*X(7)/(X(7))*min(X(7),p.NC(3))*p.MU(7);
    		X(1)/(X(1))*X(10)/(X(10))*min(X(10),p.NC(2))*p.MU(10);
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