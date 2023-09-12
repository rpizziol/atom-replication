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
%X(1)=XBrowse_2E1;
%X(2)=XE1_a;
%X(3)=XE1_E1ToE2;
%X(4)=XE2_a;
%X(5)=XE2_e;
%X(6)=XE1_e;
%X(7)=XBrowse_browse;


%task ordering
%1=Client;
%2=T1;
%3=T2;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +1,  +0,  +1,  +0;
               +0,  +0,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  -1,  +0,  +0,  +1,  +0;
               -1,  +0,  +0,  +0,  +0,  -1,  +1;
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
    Rate = [];
    Rate(isnan(Rate))=0;
end