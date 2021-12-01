function X = runModelTandem2(nClients, dt, TF)
    % Number of threads for each task
    NT_taskB = 10;
    
    % Number of processor cores for each task
    NC_taskB = 1;

    S = [NT_taskB, NC_taskB];
    
    % State vector (the queue length of each entry and task)
    %           Xtka, Atb1, Atb2,  Xtb1, Xtb2 (1:5)
    X0 = [  nClients,    0,    0,    0,    0];
    
    % Probabilities of routing to TaskB1 / TaskB2 entries
    P = [1/2, 1/2];
    
    % Service rates
    mu_taskA = 1;
    mu_taskB1 = 1/1.2e-3;
    mu_taskB2 = 1/2.1e-3;
    MU = [mu_taskA, mu_taskB1, mu_taskB2];
    
    rep = 1000; % Number of repetitions
    delta = 10^5; % Context switch rate

                  % Xtka, Atb1, Atb2,  Xtb1, Xtb2 (1:5)
    stoich_matrix=[   -1,    1,    0,    0,    0;
                      -1,    0,    1,    0,    0;
                       0,   -1,    0,    1,    0;
                       0,    0,   -1,    0,    1;
                       1,    0,    0,   -1,    0;
                       1,    0,    0,    0,   -1;];
       
    pfun = @propensities_2state;

    % Run the simulation
    X = simulateLQN(X0, S, P, MU, TF, rep, dt, delta, stoich_matrix, pfun);
end

%{
% Propensity rates function.
% @param X  State vector
% @param p  data structure with parameters
%}
function Rate = propensities_2state(X, p)
    Rate = [p.P(1)*p.delta*min(X(1),p.S(1)-sum(X(2:5))); % Xtka -> Atb1
            p.P(2)*p.delta*min(X(1),p.S(1)-sum(X(2:5))); % Xtka -> Atb2
            div(X(2),X(2)+X(3))*p.delta*min(X(2)+X(3),p.S(1)-X(4)-X(5)); % Atb1 -> Xtb1
            div(X(3),X(2)+X(3))*p.delta*min(X(2)+X(3),p.S(1)-X(4)-X(5)); % Atb2 -> Xtb2
            div(X(4),X(4)+X(5))*p.MU(2)*min(X(4)+X(5),p.S(2)); % Xtb1 -> Xtka
            div(X(5),X(4)+X(5))*p.MU(3)*min(X(4)+X(5),p.S(2)); % Xtb2 -> Xtka
        ];
end

