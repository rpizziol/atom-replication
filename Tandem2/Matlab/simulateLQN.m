
%{
% Simulate any LQN identified by the following parameters.
% @param X0     Initial state vector
% @param S      Number of threads and cores
% @param P      Routing probabilities
% @param MU     Service rates
% @param TF     Time frame
% @param rep    Number of repetitions
% @param dt     Sampling step
% @param delta  Context switch rate
% @param stoich_matrix The stoichiometric matrix
% @param pfun   The function of the propensities
% @return X     The average state vector over time (2-dimensional matrix)
%}
function X = simulateLQN(X0, S, P, MU, TF, rep, dt, delta, stoich_matrix, pfun)
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
    
    % Save all parameters in 'p'
    p.MU = MU;      
    p.S = S;
    p.delta = delta;
    p.P = P;
        
    tspan = [0, TF];
    
    % Run the simulation
    X = zeros(length(X0), ceil(TF/dt) + 1, rep);
    for i = 1:rep
        [t,x] = directMethod(stoich_matrix, pfun, tspan, X0, p);
        tsin = timeseries(x, t);
        tsout = resample(tsin, linspace(0, TF, ceil(TF/dt) + 1), 'zoh');
        X(:, :, i) = tsout.Data';
    end
    X = mean(X,3); % Mediate all repetitions (simulations)
end