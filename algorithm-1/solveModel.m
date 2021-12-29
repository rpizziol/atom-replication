function [fval, c] = solveModel(modelName, N, M, psi, tau1, tau2, Cmax, rt, st)
    %% Calculate total allocated CPU capacity (to minimize)
    Ct = sum(rt.*st); 
    Chat = Ct / Cmax; % Normalized Ct

    system("cd LQNFiles; java -jar DiffLQN.jar " + modelName + "-temp.lqn");

    Xt = zeros(N, M);
    m = readmatrix(strcat('./LQNFiles/', modelName, '-temp.csv'));
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
    fval = (tau1 * Bhat - tau2 * Chat);

    c = rand(); % TODO calculate c
end

