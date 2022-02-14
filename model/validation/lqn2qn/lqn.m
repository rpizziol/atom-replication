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
%X(1)=XBrowse_2e1;
%X(2)=Xe1_a;
%X(3)=Xe1_e;
%X(4)=XBrowse_2e2;
%X(5)=Xe2_a;
%X(6)=Xe2_e;
%X(7)=XBrowse_browse;


%task ordering
%1=Client;
%2=A;
%3=B;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +0,  +0,  +0,  +0;
               -1,  +0,  -1,  +1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  -1,  +1,  +0;
               +0,  +0,  +0,  -1,  +0,  -1,  +1;
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
    Rate = [p.MU(7)*X(7);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)));
    		X(1)/(X(1))*X(3)/(X(3))*min(X(3),p.NC(2))*p.MU(3);
    		X(5)/(X(5))*p.delta*min(X(5),p.NT(3)-(X(6)));
    		X(4)/(X(4))*X(6)/(X(6))*min(X(6),p.NC(3))*p.MU(6);
    		];
    Rate(isnan(Rate))=0;
end