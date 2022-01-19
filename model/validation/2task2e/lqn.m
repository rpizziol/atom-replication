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
%X(1)=XBrowse_2ECristo;
%X(2)=XECristo_a;
%X(3)=XECristo_Choice;
%X(4)=XECristo_BlkE1;
%X(5)=XECristo_2E1;
%X(6)=XE1_a;
%X(7)=XE1_E1ToE3;
%X(8)=XE3_a;
%X(9)=XE3_e;
%X(10)=XE1_e;
%X(11)=XECristo_BlkE2;
%X(12)=XECristo_2E2;
%X(13)=XE2_a;
%X(14)=XE2_E2ToE3;
%X(15)=XE2_e;
%X(16)=XECristo_e;
%X(17)=XBrowse_browse;


%task ordering
%1=Client;
%2=TCristo;
%3=T1;
%4=T2;
%5=T3;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  +1,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  -1,  +1,  +0;
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
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)+X(4)+X(5)+X(11)+X(12)+X(16)));
    		p.delta*X(3)*0.500000;
    		p.delta*X(4);
    		X(6)/(X(6))*p.delta*min(X(6),p.NT(3)-(X(7)+X(10)));
    		X(8)/(X(8))*p.delta*min(X(8),p.NT(5)-(X(9)));
    		X(7)/(X(7)+X(14))*X(9)/(X(9))*min(X(9),p.NC(5))*p.MU(9);
    		p.delta*X(3)*0.500000;
    		p.delta*X(11);
    		X(13)/(X(13))*p.delta*min(X(13),p.NT(4)-(X(14)+X(15)));
    		X(14)/(X(7)+X(14))*X(9)/(X(9))*min(X(9),p.NC(5))*p.MU(9);
    		X(5)/(X(5))*X(10)/(X(10))*min(X(10),p.NC(3))*p.MU(10);
    		X(12)/(X(12))*X(15)/(X(15))*min(X(15),p.NC(4))*p.MU(15);
    		X(1)/(X(1))*X(16)/(X(16))*min(X(16),p.NC(2))*p.MU(16);
    		];
    Rate(isnan(Rate))=0;
end