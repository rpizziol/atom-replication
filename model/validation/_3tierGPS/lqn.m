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
%X(1)=Xbrowse_2e1;
%X(2)=Xe1_a;
%X(3)=Xe1_2e2;
%X(4)=Xe2_a;
%X(5)=Xe2_2e3;
%X(6)=Xe3_a;
%X(7)=Xe3_e;
%X(8)=Xe2_e;
%X(9)=Xe1_e;
%X(10)=Xbrowse_browse;


%task ordering
%1=Client;
%2=T1;
%3=T2;
%4=T3;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
    +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0;
    +0,  +0,  -1,  +0,  +0,  +0,  +0,  -1,  +1,  +0;
    -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
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
Rate = [p.MU(10)*X(10);
    p.delta*min(X(2),p.NT(2)-(X(3)+X(9)));
    p.delta*min(X(4),p.NT(3)-(X(5)+X(8)));
    p.delta*min(X(6),p.NT(4)-(X(7)));
    (X(7)/sum(X([7,8,9])))*min(sum(X([7,8,9])),p.NC(2))*p.MU(7);
    (X(8)/sum(X([7,8,9])))*min(sum(X([7,8,9])),p.NC(2))*p.MU(8);
    (X(9)/sum(X([7,8,9])))*min(sum(X([7,8,9])),p.NC(2))*p.MU(9);
    ];
Rate(isnan(Rate))=0;
end