function X = sock(X0,MU, TF, rep, dt)
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

p.MU = MU;      
p.delta = 10^5; % context switch rate (super fast)

              % Jump matrix
              %  Xc,    Xadd_a,    Xadd_h,    Xadd_ct,    Xadd_cr,    Xadd_e,   Xhm_a,    Xhm_e,    Xcat_a,    Xcat_lst,    Xcat_it,    Xcat_e,    Xcar_a,    Xcar_g,    Xcar_ad,    Xcar_dl,    Xcar_e,   Xlst_a,    Xlst_qry,    Xlst_e,    Xit_a,    Xit_qry,   Xit_e,    Xcatqry_a,    Xcatqry_e,    Xget_a,    Xget_qry,    Xget_e,    Xadd_a,    Xadd_qry,    Xadd_e,    Xdel_a,    Xdel_qry,    Xdel_e,    Xcrtqry_a,    Xcrtqry_e    Xr_f,    Xfe_f,    Xcatsvc_f,    Xcarsvc_f,    Xcatdb_f,    Xcardb_f         
stoich_matrix=[   0,         0,         0,          0,          0,          0,      0,        0,         0,           0,          0,         0,         0,         0,          0,          0,         0,        0,           0,         0,        0,          0,       0,            0,            0,         0,           0,         0,         0,           0,         0,         0,           0,         0,            0,            0,      0,        0,            0,            0,           0,           0];
    
tspan = [0, TF];
pfun = @propensities_2state;

% 3d matrix (n. queues x 
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
    %  X0, X1_A, X1_C, X1_E, X2_A, X2_C, X2_E, X3_A, X3_E, X1_F, X2_F, X3_F
    async=0;
    Rate = [0.5*p.MU(1)*X(1); %X0-> X1_A
            0.5*p.MU(1)*X(1); %X0-> X2_A
            p.MU(2)*X(4); %X1_E-> X0+X1_F
            p.MU(3)*X(7); %X2_E-> X0+X2_F
            p.delta*min(X(2),X(10)); %X1_A-> X1_C+X3_A-X1_F
            (1-async)*p.MU(4)*X(9)*X(3)/(X(3)+X(6)); %X1_C-> X1_E+X3_F-X3_E
            async*p.delta*X(3);
            p.delta*min(X(5),X(11)); %X2_A-> X2_C+X3_A-X2_F
            (1-async)*p.MU(4)*X(9)*X(6)/(X(3)+X(6)); %X2_C-> X2_E+X3_F-X3_E
            async*p.delta*X(6);
            p.delta*min(X(8),X(12)); %X3_A-> X3_E-X3_F
            async*p.MU(4)*X(9);
           ];
     Rate(isnan(Rate))=0;
%      disp(Rate);
%      disp(X)
end