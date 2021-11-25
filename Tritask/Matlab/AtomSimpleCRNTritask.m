
%{
% Simulate the first 4 tasks of the ATOM LQN.
% @param X0     Initial state vector
% @param S      Number of threads and cores
% @param P      Routing probabilities
% @param MU     Service rates
% @param TF     ??
% @param rep    Number of repetitions
% @param dt     Sampling step
%}
function X = AtomSimpleCRNTritask(X0, S, P, MU, TF, rep, dt)
import Gillespie.*

% Make sure vector components are doubles
X0 = double(X0);
S = double(S);
MU = double(MU);
P = double(P);

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
if(iscolumn(P))
    P=P';
end

p.MU = MU;      
p.S = S;
p.delta = 10^4; % Context switch rate (super fast)
p.P = P;

              % Xbro, Aadd, Ahom, Acat, Acar, Xhom, Xcat, Xcar, Xadd, Alis, Aite, Xlis, Xite, Frou, Ffro, Fcat  
stoich_matrix=[   -1,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0;
                   0,   -1,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,   -1,    0,    0;
                   0,   -1,    0,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0,   -1,    0,    0;
                   0,   -1,    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,    0,   -1,    0,    0;
                   0,    0,   -1,    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,    0,   -1,    0;
                   0,    0,    0,   -1,    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,   -1,    0;
                   0,    0,    0,    0,   -1,    0,    0,    1,    0,    0,    0,    0,    0,    0,   -1,    0;
                   0,    0,    0,    0,    0,   -1,    0,    0,    1,    0,    0,    0,    0,    0,    1,    0;
                   0,    0,    0,    0,    0,    0,   -1,    0,    1,    0,    0,    0,    0,    0,    1,    0;
                   0,    0,    0,    0,    0,    0,    0,   -1,    1,    0,    0,    0,    0,    0,    1,    0;
                   1,    0,    0,    0,    0,    0,    0,    0,   -1,    0,    0,    0,    0,    1,    0,    0;
                   0,    0,    0,   -1,    0,    0,    0,    0,    0,    1,    0,    0,    0,    0,   -1,    0;
                   0,    0,    0,   -1,    0,    0,    0,    0,    0,    0,    1,    0,    0,    0,   -1,    0;
                   0,    0,    0,    0,    0,    0,    0,    0,    0,   -1,    0,    1,    0,    0,    0,   -1;
                   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,   -1,    0,    1,    0,    0,   -1;
                   0,    0,    0,    0,    0,    0,    1,    0,    0,    0,    0,   -1,    0,    0,    0,    1;
                   0,    0,    0,    0,    0,    0,    1,    0,    0,    0,    0,    0,   -1,    0,    0,    1;];
    
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
            p.P(1)*p.delta*min(X(2),X(14)); % Aadd -> Ahom
            p.P(2)*p.delta*min(X(2),X(14)); % Aadd -> Acat
            p.P(3)*p.delta*min(X(2),X(14)); % Aadd -> Acar
            div(X(3),sum(X(3:5)))*p.delta*min(sum(X(3:5)),X(15)); % Ahom -> Xhom
            div(X(4),sum(X(3:5)))*p.delta*min(sum(X(3:5)),X(15)); % Acat -> Xcat
            div(X(5),sum(X(3:5)))*p.delta*min(sum(X(3:5)),X(15)); % Acar -> Xcar
            div(X(6),sum(X(6:8)))*p.MU(3)*min(sum(X(6:8)),p.S(4)); % Xhom -> Xadd
            div(X(7),sum(X(6:8)))*p.MU(4)*min(sum(X(6:8)),p.S(4)); % Xcat -> Xadd
            div(X(8),sum(X(6:8)))*p.MU(5)*min(sum(X(6:8)),p.S(4)); % Xcar -> Xadd
            p.MU(2)*min(X(9),p.S(3)); % Xadd -> Xbro
            p.P(4)*p.delta*(min(X(4), X(15))) % Acat -> Alis
            p.P(5)*p.delta*(min(X(4), X(15))) % Acat -> Aite
            div(X(10),sum(X(10:11)))*p.delta*min(sum(X(10:11)), X(16))  % Alis -> Xlis
            div(X(11),sum(X(10:11)))*p.delta*min(sum(X(10:11)), X(16))  % Aite -> Xite
            div(X(12),sum(X(12:13)))*p.MU(6)*min(sum(X(12:13)), p.S(6)) % Xlis -> Xcat
            div(X(13),sum(X(12:13)))*p.MU(7)*min(sum(X(12:13)), p.S(6)) % Xite -> Xcat
        ];
end