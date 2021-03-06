function [fval, c] = solveModel(modelName, model, params, Cmax, r, s)
    %% Calculate total allocated CPU capacity (to minimize)
    Ct = sum(r.*s); 
    Chat = Ct / Cmax; % Normalized Ct

    [status, ~] = system("cd LQNFiles; java -jar DiffLQN.jar " + modelName + ".lqn");

    if status == 0 % no error
        Xt = zeros(model.N, model.M);
        m = readmatrix(strcat('./out/', modelName, '.csv'));
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
        Bt = sum(sum(params.psi.*Xt));
        Bmax = sum(sum(params.psi.*repmat(500, model.N, model.M))); % TODO update max value (500?)
        Bhat = Bt / Bmax; % Normalized Bt
    
        %% Calculate objective function
        fval = (params.tau1 * Bhat - params.tau2 * Chat);
    
        c = rand(); % TODO calculate c
    end
end

