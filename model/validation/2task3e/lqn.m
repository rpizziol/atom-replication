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
%X(1)=XBrowse_2Address;
%X(2)=XAddress_a;
%X(3)=XAddress_2Home;
%X(4)=XHome_a;
%X(5)=XHome_e;
%X(6)=XAddress_2Catalog;
%X(7)=XCatalog_a;
%X(8)=XCatalog_e;
%X(9)=XAddress_2Cart;
%X(10)=XCart_a;
%X(11)=XCart_e;
%X(12)=XAddress_e;
%X(13)=XBrowse_browse;


%task ordering
%1=Client;
%2=Router;
%3=Front_end;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0;
               -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
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
    Rate = [p.MU(13)*X(13);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)+X(6)+X(9)+X(12)));
    		X(4)/(X(4)+X(7)+X(10))*p.delta*min(X(4)+X(7)+X(10),p.NT(3)-(X(5)+X(8)+X(11)));
    		X(3)/(X(3))*X(5)/(X(5)+X(8)+X(11))*min(X(5)+X(8)+X(11),p.NC(3))*p.MU(5);
    		X(7)/(X(4)+X(7)+X(10))*p.delta*min(X(4)+X(7)+X(10),p.NT(3)-(X(5)+X(8)+X(11)));
    		X(6)/(X(6))*X(8)/(X(5)+X(8)+X(11))*min(X(5)+X(8)+X(11),p.NC(3))*p.MU(8);
    		X(10)/(X(4)+X(7)+X(10))*p.delta*min(X(4)+X(7)+X(10),p.NT(3)-(X(5)+X(8)+X(11)));
    		X(9)/(X(9))*X(11)/(X(5)+X(8)+X(11))*min(X(5)+X(8)+X(11),p.NC(3))*p.MU(11);
    		X(1)/(X(1))*X(12)/(X(12))*min(X(12),p.NC(2))*p.MU(12);
    		];
    Rate(isnan(Rate))=0;
end