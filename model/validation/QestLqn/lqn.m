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
%X(3)=XE1_ChoiceE1;
%X(4)=XE1_BlkSynch;
%X(5)=XE1_2E2Synch;
%X(6)=XE2_a;
%X(7)=XE2_e;
%X(8)=XE1_2E2Synch_e;
%X(9)=XE1_BlkAsynch;
%X(10)=XE1_2E2Asynch;
%X(11)=XE1_2E2Asynch_e;
%X(12)=XE1_e;
%X(13)=XBrowse_browse;


%task ordering
%1=C;
%2=T1;
%3=T2;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  -1,  +1,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +1,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0;
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
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)+X(4)+X(5)+X(5)_e+X(9)+X(10)+X(10)_e+X(12)));
    		p.delta*X(3)*P_synch;
    		p.delta*X(4);
    		X(6)/(X(6))*p.delta*min(X(6),p.NT(3)-(X(7)));
    		X(5)/(X(5)+X(10))*X(7)/(X(7))*min(X(7),p.NC(3))*p.MU(7);
    		p.delta*X(3)*P_asynch;
    		p.delta*X(9);
    		X(10)/(X(5)+X(10))*X(7)/(X(7))*min(X(7),p.NC(3))*p.MU(7);
    		X(5)/(X(5)+X(10))*X(5)_e/(X(12))*min(X(12),p.NC(2))*p.MU(8);
    		X(10)/(X(5)+X(10))*X(10)_e/(X(12))*min(X(12),p.NC(2))*p.MU(11);
    		X(1)/(X(1))*X(12)/(X(12))*min(X(12),p.NC(2))*p.MU(12);
    		];
    Rate(isnan(Rate))=0;
end