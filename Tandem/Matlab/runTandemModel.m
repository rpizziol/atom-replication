function X = runTandemModel(nClients, TF, dt)
    % Number of processor cores for each task
    NC_router = 1;
    NT_router = 10;
    
    S = [NT_router, NC_router];
    
    % State vector (the queue length of each entry and task)
    %           Xbro, Aadd, Xadd
    X0 = [  nClients,    0,   0];
    
    % Service rates
    mu_bro = 1;
    mu_add = 1/1.2e-3;
    
    MU = [mu_bro, mu_add];
    
    rep = 1000;    % Number of repetitions
    delta = 10^5; % Context switch rate
    
                  % Xbro, Aadd, Xadd
    stoich_matrix=[   -1,    1,    0;
                       0,   -1,    1;
                       1,    0,   -1];

    pfun = @propensities_2state;

    P = [0, 0]; % Placeholder, useless values

    % Run the simulation
    X = simulateLQN(X0, S, P, MU, TF, rep, dt, delta, stoich_matrix, pfun);
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

