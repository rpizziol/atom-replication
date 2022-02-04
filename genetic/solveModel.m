function [fval, rt] = solveModel(modelName, model, params, Cmax, r, s)
    %% Calculate total allocated CPU capacity (to minimize)
    Ct = sum(s);  %sum(r.*s); 
    Chat = Ct / Cmax; % Normalized Ct

    [status, ~] = system("cd out; lqns -x " + modelName + ".lqnx");
    %[status, ~] = system("cd out; lqsim -x " + modelName + ".lqn");
    %[status, ~] = system("cd out; java -jar DiffLQN.jar " + modelName + ".lqn");
    %[status, ~] = system("java -jar ./out/DiffLQN.jar " + temppath);

    if status == 0 % no error
        Xt = zeros(model.N, model.M);
        %m = readmatrix(strcat('./out/', modelName, '.csv'));

        xdoc = xmlread(strcat('./out/', modelName, '.lqxo'));
        entry = xdoc.getElementsByTagName('result-entry');
        % getElementsByTagName (name) invece di item(0), item(1)
        
        % EntryBrowse
        Xt(1,1) = str2double(entry.item(0).getAttribute('throughput'));
        % EntryAddress
        Xt(2,1) = str2double(entry.item(1).getAttribute('throughput'));
        % EntryHome EntryCatalog EntryCarts
        Xt(3,1) = str2double(entry.item(2).getAttribute('throughput'));
        Xt(3,2) = str2double(entry.item(3).getAttribute('throughput'));
        Xt(3,3) = str2double(entry.item(4).getAttribute('throughput'));
        % EntryList EntryItem
        Xt(4,1) = str2double(entry.item(5).getAttribute('throughput'));
        Xt(4,2) = str2double(entry.item(6).getAttribute('throughput'));
        % EntryGet EntryAdd EntryDelete
        Xt(5,1) = str2double(entry.item(7).getAttribute('throughput'));
        Xt(5,2) = str2double(entry.item(8).getAttribute('throughput'));
        Xt(5,3) = str2double(entry.item(9).getAttribute('throughput'));
        % EntryQueryCatalog
        Xt(6,1) = str2double(entry.item(10).getAttribute('throughput'));
        % EntryQueryCartsdb
        Xt(7,1) = str2double(entry.item(11).getAttribute('throughput'));
    
        %% Calculate revenue (to maximize)
        Bt = sum(sum(params.psi.*Xt));
        Bmax = sum(sum(params.psi.*repmat(428.5714, model.N, model.M))); % nuser (3000) / 7 (think time)
        Bhat = Bt / Bmax; % Normalized Bt
    
        %% Calculate objective function
        fval = (params.tau1 * Bhat - params.tau2 * Chat);

        %% Obtain response times
        rt = zeros(1, 9);
        for i = 1:9
            rt(i) = str2double(entry.item(i).getAttribute('phase1-service-time'));
        end
    end
end

