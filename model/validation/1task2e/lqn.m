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
%X(1)=XBrowse_2Address1;
%X(2)=XAddress1_a;
%X(3)=XAddress1_e;
%X(4)=XBrowse_2Address2;
%X(5)=XAddress2_a;
%X(6)=XAddress2_e;
%X(7)=XBrowse_browse;


%task ordering
%1=Client;
%2=Router;


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
    disp(t(end-3:end))
    disp(x(end-3:end,:))
    tsin = timeseries(x,t);
    tsout = resample(tsin, linspace(0, TF, ceil(TF/dt)+1), 'zoh');
    X(:, :, i) = tsout.Data';
end

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
    Rate = [p.MU(7)*X(7);
    		X(2)/(X(2)+X(5))*p.delta*min(X(2)+X(5),p.NT(2)-(X(3)+X(6)));
    		X(1)/(X(1))*X(3)/(X(3)+X(6))*min(X(3)+X(6),p.NC(2))*p.MU(3);
    		X(5)/(X(2)+X(5))*p.delta*min(X(2)+X(5),p.NT(2)-(X(3)+X(6)));
    		X(4)/(X(4))*X(6)/(X(3)+X(6))*min(X(3)+X(6),p.NC(2))*p.MU(6);
    		];
    Rate(isnan(Rate))=0;
end