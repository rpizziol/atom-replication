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
        xmlpath = strcat('./out/', modelName, '.lqxo');
        % EntryBrowse
        Xt(1,1) = str2double(getAttributeByEntry(xmlpath, 'EntryBrowse', 'throughput'));
        % EntryAddress
        Xt(2,1) = str2double(getAttributeByEntry(xmlpath, 'EntryAddress', 'throughput'));
        % EntryHome EntryCatalog EntryCarts
        Xt(3,1) = str2double(getAttributeByEntry(xmlpath, 'EntryHome', 'throughput'));
        Xt(3,2) = str2double(getAttributeByEntry(xmlpath, 'EntryCatalog', 'throughput'));
        Xt(3,3) = str2double(getAttributeByEntry(xmlpath, 'EntryCarts', 'throughput'));
        % EntryList EntryItem
        Xt(4,1) = str2double(getAttributeByEntry(xmlpath, 'EntryList', 'throughput'));
        Xt(4,2) = str2double(getAttributeByEntry(xmlpath, 'EntryItem', 'throughput'));
        % EntryGet EntryAdd EntryDelete
        Xt(5,1) = str2double(getAttributeByEntry(xmlpath, 'EntryGet', 'throughput'));
        Xt(5,2) = str2double(getAttributeByEntry(xmlpath, 'EntryAdd', 'throughput'));
        Xt(5,3) = str2double(getAttributeByEntry(xmlpath, 'EntryDelete', 'throughput'));
        % EntryQueryCatalog
        Xt(6,1) = str2double(getAttributeByEntry(xmlpath, 'EntryQueryCatalog', 'throughput'));
        % EntryQueryCartsdb
        Xt(7,1) = str2double(getAttributeByEntry(xmlpath, 'EntryQueryCartsdb', 'throughput'));
    
        %% Calculate revenue (to maximize)
        Bt = sum(sum(params.psi.*Xt));
        Bmax = sum(sum(params.psi.*repmat(428.5714, model.N, model.M))); % nuser (3000) / 7 (think time)
        Bhat = Bt / Bmax; % Normalized Bt
    
        %% Calculate objective function
        fval = (params.tau1 * Bhat - params.tau2 * Chat);

        %% Obtain response times
        rt = zeros(1, 9);
        entrynames = ["EntryAddress" "EntryHome" "EntryCatalog" ...
            "EntryCarts" "EntryList" "EntryItem" "EntryGet" "EntryAdd" ...
            "EntryDelete"];

        for i = 1:9
            rt(i) = str2double(getAttributeByEntry(xmlpath, entrynames(i), 'phase1-service-time'));
            % i+1 in order to skip EntryBrowse
            %rt(i) = str2double(entry.item(i+1).getAttribute('phase1-service-time'));
        end
    end
end

% xpath query