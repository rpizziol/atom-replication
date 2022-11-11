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
%X(3)=Xe1_e1Toe3;
%X(4)=Xe3_a;
%X(5)=Xe3_e;
%X(6)=Xe1_e1Toe4;
%X(7)=Xe4_a;
%X(8)=Xe4_e;
%X(9)=Xe1_e;
%X(10)=Xbrowse_2e2;
%X(11)=Xe2_a;
%X(12)=Xe2_e2Toe1;
%X(13)=Xe2_e2Toe3;
%X(14)=Xe2_e2Toe4;
%X(15)=Xe2_e;
%X(16)=Xbrowse_browse;


%task ordering
%1=Client;
%2=T1;
%3=T2;
%4=T3;
%5=T4;


% Jump matrix
stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
               +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
               -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0;
               +0,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0;
               +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  -1,  +1,  +0,  +0,  +0;
               +0,  +0,  +0,  +0,  -1,  +0,  +1,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0;
               +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  -1,  +1;
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
    Rate = [p.MU(16)*X(16);
    		X(2)/(X(2))*p.delta*min(X(2),p.NT(2)-(X(3)+X(6)+X(9)));
    		X(4)/(X(4))*p.delta*min(X(4),p.NT(4)-(X(5)));
    		X(3)/(X(3)+X(13))*X(5)/(X(5))*min(X(5),p.NC(4))*p.MU(5);
    		X(7)/(X(7))*p.delta*min(X(7),p.NT(5)-(X(8)));
    		X(6)/(X(6)+X(14))*X(8)/(X(8))*min(X(8),p.NC(5))*p.MU(8);
    		X(1)/(X(1)+X(12))*X(9)/(X(9))*min(X(9),p.NC(2))*p.MU(9);
    		X(11)/(X(11))*p.delta*min(X(11),p.NT(3)-(X(12)+X(13)+X(14)+X(15)));
    		X(12)/(X(1)+X(12))*X(9)/(X(9))*min(X(9),p.NC(2))*p.MU(9);
    		X(13)/(X(3)+X(13))*X(5)/(X(5))*min(X(5),p.NC(4))*p.MU(5);
    		X(14)/(X(6)+X(14))*X(8)/(X(8))*min(X(8),p.NC(5))*p.MU(8);
    		X(10)/(X(10))*X(15)/(X(15))*min(X(15),p.NC(3))*p.MU(15);
    		];
    Rate(isnan(Rate))=0;
end