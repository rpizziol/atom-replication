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
%X(3)=XAddress_Choice;
%X(4)=XAddress_AddrBlk1;
%X(5)=XAddress_2Home;
%X(6)=XHome_a;
%X(7)=XHome_e;
%X(8)=XAddress_AddrBlk2;
%X(9)=XAddress_2Catalog;
%X(10)=XCatalog_a;
%X(11)=XCatalog_e;
%X(12)=XAddress_AddrBlk3;
%X(13)=XAddress_2Cart;
%X(14)=XCart_a;
%X(15)=XCart_e;
%X(16)=XAddress_e;
%X(17)=XBrowse_browse;


%task ordering
%1=Client;
%2=Router;
%3=Front_end;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  -1,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +0,  +0,  +0,  +0,  +1,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0;
               -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1;
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
    Rate = [p.MU(17)*X(17);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)+X(4)+X(5)+X(8)+X(9)+X(12)+X(13)+X(16)));
    		p.delta*X(3)*0.333333;
    		p.delta*X(4);
    		X(6)/(X(6)+X(10)+X(14))*p.delta*min(X(6)+X(10)+X(14),p.NT(3)-(X(7)+X(11)+X(15)));
    		p.delta*X(3)*0.333333;
    		p.delta*X(8);
    		X(10)/(X(6)+X(10)+X(14))*p.delta*min(X(6)+X(10)+X(14),p.NT(3)-(X(7)+X(11)+X(15)));
    		p.delta*X(3)*0.333333;
    		p.delta*X(12);
    		X(14)/(X(6)+X(10)+X(14))*p.delta*min(X(6)+X(10)+X(14),p.NT(3)-(X(7)+X(11)+X(15)));
    		X(5)/(X(5))*X(7)/(X(7)+X(11)+X(15))*min(X(7)+X(11)+X(15),p.NC(3))*p.MU(7);
    		X(9)/(X(9))*X(11)/(X(7)+X(11)+X(15))*min(X(7)+X(11)+X(15),p.NC(3))*p.MU(11);
    		X(13)/(X(13))*X(15)/(X(7)+X(11)+X(15))*min(X(7)+X(11)+X(15),p.NC(3))*p.MU(15);
    		X(1)/(X(1))*X(16)/(X(7)+X(11)+X(15))*min(X(7)+X(11)+X(15),p.NC(3))*p.MU(16);
    		];
    Rate(isnan(Rate))=0;
end