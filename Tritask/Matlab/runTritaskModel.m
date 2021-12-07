function X = runTritaskModel(nClients, TF, dt)
    % Number of threads for each task
    NT_froend = 10;
    NT_router = 10;
    
    % Number of processor cores for each task
    NC_router = 10;
    NC_froend = 10;
    
    S = [NT_router, NT_froend, NC_router, NC_froend];
    
    % State vector (the queue length of each entry and task)
    %           Xbro, Aadd, Ahom,  Acat, Acar, Xhom, Xcat, Xcar, Xadd (1:9)
    X0 = [  nClients,    0,    0,    0,    0,    0,    0,    0,    0];
    
    % Service rates
    mu_bro = 1; %/7.0e-3;
    mu_add = 1/(1.2e-3);
    mu_hom = 1/(2.1e-3);
    mu_cat = 1/(3.7e-3);
    mu_car = 1/(5.1e-3);
    
    MU = [mu_bro, mu_add, mu_hom, mu_cat, mu_car];
    
    rep = 1000;    % Number of repetitions
    delta = 10^5; % Context switch rate
    
              % Xbro, Aadd, Ahom, Acat, Acar, Xhom, Xcat, Xcar, Xadd  
    stoich_matrix=[   -1,    1,    0,    0,    0,    0,    0,    0,    0;
                       0,   -1,    1,    0,    0,    0,    0,    0,    0;
                       0,   -1,    0,    1,    0,    0,    0,    0,    0;
                       0,   -1,    0,    0,    1,    0,    0,    0,    0;
                       0,    0,   -1,    0,    0,    1,    0,    0,    0;
                       0,    0,    0,   -1,    0,    0,    1,    0,    0;
                       0,    0,    0,    0,   -1,    0,    0,    1,    0;
                       0,    0,    0,    0,    0,   -1,    0,    0,    1;
                       0,    0,    0,    0,    0,    0,   -1,    0,    1;
                       0,    0,    0,    0,    0,    0,    0,   -1,    1;
                       1,    0,    0,    0,    0,    0,    0,    0,   -1;];

    pfun = @propensities_2state;

    % Array of routing probabilities
    P = [1/3, 1/3, 1/3];

    % Run the simulation
    X = simulateLQN(X0, S, P, MU, TF, rep, dt, delta, stoich_matrix, pfun);
end

%{
% Propensity rates function.
% @param X  State vector (Xbro, Aadd, Ahom,  Acat, Acar, Xhom, Xcat, Xcar, Xadd (1:9))
% @param p  data structure with parameters
%}
function Rate = propensities_2state(X, p)
    Rate = [p.MU(1)*X(1); % Xbro -> Aadd
            p.P(1)*p.delta*min(X(2),p.S(1)-sum(X(3:9))); % Aadd -> Ahom
            p.P(2)*p.delta*min(X(2),p.S(1)-sum(X(3:9))); % Aadd -> Acat
            p.P(3)*p.delta*min(X(2),p.S(1)-sum(X(3:9))); % Aadd -> Acar
            div(X(3),sum(X(3:5)))*p.delta*min(sum(X(3:5)),p.S(2)-sum(X(6:8))); % Ahom -> Xhom
            div(X(4),sum(X(3:5)))*p.delta*min(sum(X(3:5)),p.S(2)-sum(X(6:8))); % Acat -> Xcat
            div(X(5),sum(X(3:5)))*p.delta*min(sum(X(3:5)),p.S(2)-sum(X(6:8))); % Acar -> Xcar
            div(X(6),sum(X(6:8)))*p.MU(3)*min(sum(X(6:8)),p.S(4)); % Xhom -> Xadd
            div(X(7),sum(X(6:8)))*p.MU(4)*min(sum(X(6:8)),p.S(4)); % Xcat -> Xadd
            div(X(8),sum(X(6:8)))*p.MU(5)*min(sum(X(6:8)),p.S(4)); % Xcar -> Xadd
            p.MU(2)*min(X(9),p.S(3)); % Xadd -> Xbro
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

