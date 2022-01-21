function fval = solveModel(modelName, model, params, Cmax, r, s)
    %% Calculate total allocated CPU capacity (to minimize)
    Ct = sum(s);  %sum(r.*s); 
    Chat = Ct / Cmax; % Normalized Ct

    %[status, ~] = system("cd out; lqsim " + modelName + ".lqn");
    [status, ~] = system("cd out; java -jar DiffLQN.jar " + modelName + ".lqn");
    %[status, ~] = system("java -jar ./out/DiffLQN.jar " + temppath);

    if status == 0 % no error
        Xt = zeros(model.N, model.M);
        m = readmatrix(strcat('./out/', modelName, '.csv'));
        Xt(1,1) = m(1,4); % EntryBrowse
        Xt(2,1) = m(2,4); % EntryAddress
        % EntryHome EntryCatalog EntryCarts
        Xt(3,1) = m(3,4);
        Xt(3,2) = m(4,4);
        Xt(3,3) = m(5,4);
    
        %% Calculate revenue (to maximize)
        Bt = sum(sum(params.psi.*Xt));
        Bmax = sum(sum(params.psi.*repmat(428.5714, model.N, model.M))); % nuser (3000) / 7 (think time)
        Bhat = Bt / Bmax; % Normalized Bt
    
        %% Calculate objective function
        fval = (params.tau1 * Bhat - params.tau2 * Chat);
    end
end

