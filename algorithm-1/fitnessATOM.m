function value = fitnessATOM(rt, st, N, M, psi, Cmax, tau1, tau2, modelName)    
    %% Calculate total allocated CPU capacity (to minimize)
    Ct = sum(rt.*st); 
    Chat = Ct / Cmax; % Normalized Ct

    %% Solve model and calculate Xt
    % Xt = Number of transactions per unit time for a give period t and a
    % particular class j of microservice i (TODO calculate with LQNS)
    
    updateReplication(rt, modelName);
    % updateCalls(rt); % TODO implement this method
    % updateHostDemand(st); % TODO implement this method
    
    system('./LQN-exec.sh'); % solve model

    Xt = zeros(N, M);
    m = readmatrix(strcat(modelName, '-temp.csv'));
    Xt(1,1) = m(1,4); % EntryBrowse
    Xt(2,1) = m(2,4); % EntryAddress
    % EntryHome EntryCatalog EntryCarts
    Xt(3,1) = m(3,4);
    Xt(3,2) = m(4,4);
    Xt(3,3) = m(5,4);
    % EntryList EntryItem
    Xt(4,1) = m(6,4);
    Xt(4,2) = m(7,4);

    %% Calculate revenue (to maximize)
    Bt = sum(sum(psi.*Xt));
    Bmax = sum(sum(psi.*repmat(500, N, M))); % TODO update max value (500?)
    Bhat = Bt / Bmax; % Normalized Bt

    %% Calculate objective function
    value = (tau1 * Bhat - tau2 * Chat);
    value = -value; % This is just for optimtool (minimize)
end
