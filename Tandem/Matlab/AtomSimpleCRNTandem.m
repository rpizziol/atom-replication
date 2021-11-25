%{
% Simulate the first 2 tasks of the ATOM LQN.
% @param X0     Initial state vector
% @param S      Number of threads and cores
% @param MU     Service rates
% @param TF     ??
% @param rep    Number of repetitions
% @param dt     Sampling step
%}
function X = AtomSimpleCRNTandem(X0, S, MU, TF, rep, dt)
import Gillespie.*

% Make sure vector components are doubles
X0 = double(X0);
S = double(S);
MU = double(MU);

% Make sure all vectors are row vectors
if(iscolumn(X0))
    X0=X0';
end
if(iscolumn(S))
    S=S';
end
if(iscolumn(MU))
    MU=MU';
end

p.MU = MU;      
p.S = S;
p.delta = 10^5; % Context switch rate (super fast)

              % Xbro, Aadd, Xadd
stoich_matrix=[   -1,    1,    0;
                   0,   -1,    1;
                   1,    0,   -1];
                   
tspan = [0, TF];
pfun = @propensities_2state;

% Run the simulation
X = zeros(length(X0), ceil(TF/dt) + 1, rep);
for i = 1:rep
    [t,x] = directMethod(stoich_matrix, pfun, tspan, X0, p);
    tsin = timeseries(x, t);
    tsout = resample(tsin, linspace(0, TF, ceil(TF/dt) + 1), 'zoh');
    X(:, :, i) = tsout.Data';
end

end

%{
% Propensity rates function.
% @param X  State vector
% @param p  data structure with parameters
%}
function Rate = propensities_2state(X, p)
    Rate = [p.MU(1)*X(1); % Xbro -> Aadd
            p.delta*min(X(2), p.S(1)-X(3)); % Aadd -> Xadd
            p.MU(2)*min(X(3), p.S(2)); % Xadd -> Xbro
        ];
end
