% Solve the LQN model by means of lqns
% INPUTS
%   modelName   : the path to the lqnx model.
%   model       : a structure containing information about the model.
%   params      : a structure containing parameters of the optimization.
%   constraints : the constraints of the optimization.
%   s           : the CPU share array.
%   nuser       : the number of users in the model.
% OUTPUTS
%   fval        : the value of the objective function given s.
function fval = solveModel(modelName, model, params, s, nuser)
    %% Calculate total allocated CPU capacity (to minimize)
    Cmax = sum(params.s_ub); %constraints.Q.*constraints.s_ub);
    Ct = sum(s);  %sum(r.*s); 
    Chat = Ct / Cmax; % Normalized Ct

    [status, ~] = system("lqns -x " + modelName + "." + model.extension);

    if status == 0 % no error
        % TODO read by means of xpath queries.
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

        Bmax = sum(sum(params.psi.*repmat(nuser / 7, model.N, model.M))); % nuser (3000) / 7 (think time)
        Bhat = Bt / Bmax; % Normalized Bt
    
        %% Calculate objective function
        fval = (params.tau1 * Bhat - params.tau2 * Chat);
        %% Obtain response times
%         rt = zeros(1, 9);
%         entrynames = ["EntryAddress" "EntryHome" "EntryCatalog" ...
%             "EntryCarts" "EntryList" "EntryItem" "EntryGet" "EntryAdd" ...
%             "EntryDelete"];
% 
%         for i = 1:9
%             rt(i) = str2double(getAttributeByEntry(xmlpath, entrynames(i), 'phase1-service-time'));
%         end
    end
    %% Remove xml files
    delete(strcat('./out/', modelName, '.out'));
    delete(strcat('./out/', modelName, '.lqnx'));
    delete(strcat('./out/', modelName, '.lqxo'));
end