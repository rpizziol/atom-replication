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
%X(1)=Xb_s;
%X(2)=Xms
%X(3)=Xc1;
%X(4)=Xc2;
%X(5)=Xb;


%task ordering
%1=Client;
%2=MS;

p.Pc1=0.5;
p.Pc2=0.5;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  -1;
               +0,  -1,  +1,  +0,  +0;
               +0,  -1,  +0,  +1,  +0;
               -1,  +0,  -1,  +0,  +1;
               -1,  +0,  +0,  -1,  +1;
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
    Tms=p.delta*min(p.NT(2)-(X(3)+X(4)),X(2));
    Rate = [p.MU(end)*X(end);
            p.Pc1*Tms;
            p.Pc2*Tms;
            X(3)/(X(3)+X(4))*p.MU(3)*min((X(3)+X(4)),p.NC(2));
            X(4)/(X(3)+X(4))*p.MU(4)*min((X(3)+X(4)),p.NC(2))
           ];
    Rate(isnan(Rate))=0;
end