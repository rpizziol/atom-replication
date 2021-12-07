function X = runTandem2Model(nClients, TF, dt)
    % Number of processor cores for each task
    NC_taskB = 1;
    NT_taskB = 10;
    % NT_taskA = inf; % Unused
    
    S = [NT_taskB, NC_taskB];
    
    % State vector (the queue length of each entry and task)
    %           Xtka, Atb1, Atb2,  Xtb1, Xtb2 (1:5)
    X0 = [  nClients,    0,    0,    0,    0];
    
    % Service rates
    mu_taskA = 1;
    mu_taskB1 = 1/(1.2e-3);
    mu_taskB2 = 1/(2.1e-3);
    MU = [mu_taskA, mu_taskB1, mu_taskB2];
    
    rep = 1000;    % Number of repetitions
    delta = 10^5; % Context switch rate
    
                  % Xtka, Atb1, Atb2,  Xtb1, Xtb2 (1:5)
    stoich_matrix=[   -1,    1,    0,    0,    0;
                      -1,    0,    1,    0,    0;
                       0,   -1,    0,    1,    0;
                       0,    0,   -1,    0,    1;
                       1,    0,    0,   -1,    0;
                       1,    0,    0,    0,   -1;];

    pfun = @propensities_2state;

    % Array of routing probabilities
    P = [1/2, 1/2];

    % Run the simulation
    X = simulateLQN(X0, S, P, MU, TF, rep, dt, delta, stoich_matrix, pfun);
end

%{
% Propensity rates function.
% @param X  State vector (Xtka, Atb1, Atb2,  Xtb1, Xtb2 (1:5))
% @param p  data structure with parameters
%}
function Rate = propensities_2state(X, p)
   %Rate = [p.P(1)*p.MU(1)*min(X(1),p.S(1)-sum(X(2:5))); % Xtka -> Atb1 (old) 
   %        p.P(2)*p.MU(1)*min(X(1),p.S(1)-sum(X(2:5))); % Xtka -> Atb2 (old)
    Rate = [p.P(1)*p.MU(1)*X(1); % Xtka -> Atb1 (since NT_taskA = inf)
            p.P(2)*p.MU(1)*X(1); % Xtka -> Atb2 (since NT_taskA = inf)
            div(X(2),sum(X(2:3)))*p.delta*min(sum(X(2:3)),p.S(1)-sum(X(4:5))); % Atb1 -> Xtb1
            div(X(3),sum(X(2:3)))*p.delta*min(sum(X(2:3)),p.S(1)-sum(X(4:5))); % Atb2 -> Xtb2
            div(X(4),sum(X(4:5)))*p.MU(2)*min(sum(X(4:5)),p.S(2)); % Xtb1 -> Xtka
            div(X(5),sum(X(4:5)))*p.MU(3)*min(sum(X(4:5)),p.S(2)); % Xtb2 -> Xtka
        ];
end

% Divide x by y (handle division by 0 as 0)
function d = div(x,y)
    if(y == 0)
        d = 0;
    else
        d = x/y;
    end
end

